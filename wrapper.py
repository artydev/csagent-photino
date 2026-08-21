#!/usr/bin/env python3
"""
wrap_photino.py - Bundle Photino AOT into single executable with debug suppression.
Final version: suppresses both stdout and stderr.

Usage:
    python3 wrap_photino_final.py <project_dir> [--output <name>] [--suppress-debug]
"""

import os
import sys
import subprocess
import tempfile
import argparse


def bin2c(data, varname):
    """Convert binary data to a C byte array."""
    lines = [f"static unsigned char {varname}[] = {{"]
    for i in range(0, len(data), 12):
        chunk = data[i:i+12]
        hex_bytes = ", ".join(f"0x{b:02x}" for b in chunk)
        lines.append(f"    {hex_bytes},")
    lines.append("};")
    lines.append(f"static unsigned int {varname}_len = {len(data)};")
    return "\n".join(lines)


def generate_c_wrapper(files, suppress_debug=False):
    """Generate C source code for wrapper."""
    parts = []
    parts.append("""/*
 * Photino Single-File Wrapper
 * Suppresses both stdout and stderr if --suppress-debug is used
 */

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <errno.h>
#include <libgen.h>
#include <fcntl.h>

""")

    # Generate embedded data
    var_names = {}
    for rel_path, (data, mode) in sorted(files.items()):
        varname = "file_" + rel_path.replace("/", "_").replace(".", "_").replace("-", "_")
        var_names[rel_path] = (varname, mode)
        parts.append(bin2c(data, varname))
        parts.append("")

    parts.append("""
static int write_file(const char *path,
                      const unsigned char *data,
                      unsigned int len, int mode)
{
    FILE *f = fopen(path, "wb");
    if (!f) {
        fprintf(stderr, "Error: cannot write %s: %s\\n",
                path, strerror(errno));
        return -1;
    }
    if (fwrite(data, 1, len, f) != len) {
        fprintf(stderr, "Error: short write to %s\\n", path);
        fclose(f);
        return -1;
    }
    fclose(f);
    if (chmod(path, mode) != 0) {
        fprintf(stderr, "Error: chmod %s: %s\\n",
                path, strerror(errno));
        return -1;
    }
    return 0;
}

static int mkdir_p(const char *dir) {
    char tmp[4096];
    char *p = NULL;
    size_t len;

    snprintf(tmp, sizeof(tmp), "%s", dir);
    len = strlen(tmp);
    if (tmp[len - 1] == '/')
        tmp[len - 1] = 0;
    for (p = tmp + 1; *p; p++) {
        if (*p == '/') {
            *p = 0;
            mkdir(tmp, 0755);
            *p = '/';
        }
    }
    return mkdir(tmp, 0755);
}

/* Copy a file from the temp dir back to the original working directory.
 * This preserves runtime-generated files (e.g. agent_memory.json) that the
 * app writes to its current working directory, which is the temp dir. */
static void copy_back(const char *tmpdir, const char *orig_cwd, const char *name)
{
    char src[4096];
    char dst[4096];
    FILE *in, *out;
    char buf[65536];
    size_t n;

    snprintf(src, sizeof(src), "%s/%s", tmpdir, name);
    snprintf(dst, sizeof(dst), "%s/%s", orig_cwd, name);

    in = fopen(src, "rb");
    if (!in)
        return;  /* file was not generated — nothing to copy */
    out = fopen(dst, "wb");
    if (!out) {
        fclose(in);
        return;
    }
    while ((n = fread(buf, 1, sizeof(buf), in)) > 0)
        fwrite(buf, 1, n, out);
    fclose(in);
    fclose(out);
}

static void cleanup_files(const char *tmpdir)
{
    char path[4096];
""")

    # Cleanup code
    parts.append("    /* Clean up all embedded files */")
    for rel_path in reversed(sorted(files.keys(), key=lambda x: -x.count('/'))):
        parts.append(f'    snprintf(path, sizeof(path), "%s/{rel_path}", tmpdir);')
        parts.append('    (void)unlink(path);')

    dirs = set()
    for rel_path in files:
        d = os.path.dirname(rel_path)
        if d:
            dirs.add(d)

    parts.append("    /* Clean up directory structure */")
    for d in reversed(sorted(dirs, key=lambda x: -x.count('/'))):
        parts.append(f'    snprintf(path, sizeof(path), "%s/{d}", tmpdir);')
        parts.append('    (void)rmdir(path);')

    parts.append('    (void)rmdir(tmpdir);')
    parts.append('}')
    parts.append('')

    parts.append("""int main(int argc, char *argv[]) {
    char tmpdir[4096];
    char path[4096];
    char orig_cwd[4096];
    char *env;
    char new_ld_path[8192];
    const char *main_binary;
    pid_t pid;
    int status;
    int devnull = -1;

    /* Remember the original working directory so runtime-generated files
     * (e.g. agent_memory.json) can be copied back after the app exits. */
    if (getcwd(orig_cwd, sizeof(orig_cwd)) == NULL) {
        fprintf(stderr, "Error: getcwd failed: %s\\n", strerror(errno));
        return 1;
    }

    /* Create a temporary directory */
    snprintf(tmpdir, sizeof(tmpdir), "/tmp/photino_wrapper_XXXXXX");
    if (mkdtemp(tmpdir) == NULL) {
        fprintf(stderr, "Error: mkdtemp failed: %s\\n", strerror(errno));
        return 1;
    }

""")

    # Find main binary
    main_binary_name = None
    for rel_path, (data, mode) in sorted(files.items()):
        if mode & 0o111:
            main_binary_name = rel_path
            break
    if not main_binary_name:
        main_binary_name = "PhotinoAOT"

    # Collect directories
    dirs = set()
    for rel_path in files:
        d = os.path.dirname(rel_path)
        if d:
            dirs.add(d)

    # Create directories
    parts.append("    /* Create directory structure */")
    for d in sorted(dirs):
        parts.append(f'    snprintf(path, sizeof(path), "%s/{d}", tmpdir);')
        parts.append('    mkdir_p(path);')
    parts.append("")

    # Write files
    parts.append("    /* Write all files */")
    for rel_path, (data, mode) in sorted(files.items()):
        varname, file_mode = var_names[rel_path]
        parts.append(f'    snprintf(path, sizeof(path), "%s/{rel_path}", tmpdir);')
        parts.append(f'    if (write_file(path, {varname}, {varname}_len, 0{oct(mode)[2:]}) != 0) {{')
        parts.append('        cleanup_files(tmpdir);')
        parts.append('        return 1;')
        parts.append('    }')
    parts.append("")

    # Set LD_LIBRARY_PATH
    parts.append("    /* Set LD_LIBRARY_PATH */")
    parts.append('    env = getenv("LD_LIBRARY_PATH");')
    parts.append('    if (env && env[0]) {')
    parts.append('        snprintf(new_ld_path, sizeof(new_ld_path), "%s:%s", tmpdir, env);')
    parts.append('    } else {')
    parts.append('        snprintf(new_ld_path, sizeof(new_ld_path), "%s", tmpdir);')
    parts.append('    }')
    parts.append('    setenv("LD_LIBRARY_PATH", new_ld_path, 1);')
    parts.append("")

    # Change directory
    parts.append("    /* Change to temp directory */")
    parts.append('    if (chdir(tmpdir) != 0) {')
    parts.append('        fprintf(stderr, "Error: chdir to %s: %s\\n", tmpdir, strerror(errno));')
    parts.append('        cleanup_files(tmpdir);')
    parts.append('        return 1;')
    parts.append('    }')
    parts.append("")

    # If suppressing debug, open /dev/null now (before fork)
    if suppress_debug:
        parts.append('    /* Suppress output: open /dev/null */')
        parts.append('    devnull = open("/dev/null", O_WRONLY);')
        parts.append('    if (devnull < 0) {')
        parts.append('        devnull = open("/dev/null", O_WRONLY | O_CREAT, 0666);')
        parts.append('    }')
        parts.append('')

    # Fork and execute
    parts.append('    /* Fork child process */')
    parts.append('    pid = fork();')
    parts.append('    if (pid < 0) {')
    parts.append('        fprintf(stderr, "Error: fork failed: %s\\n", strerror(errno));')
    parts.append('        cleanup_files(tmpdir);')
    parts.append('        return 1;')
    parts.append('    }')
    parts.append('')
    parts.append('    if (pid == 0) {')
    parts.append('        /* Child process */')

    if suppress_debug:
        parts.append('        /* Suppress BOTH stdout and stderr */')
        parts.append('        if (devnull >= 0) {')
        parts.append('            fflush(stdout);')
        parts.append('            fflush(stderr);')
        parts.append('            dup2(devnull, STDOUT_FILENO);  /* Redirect stdout */')
        parts.append('            dup2(devnull, STDERR_FILENO);  /* Redirect stderr */')
        parts.append('            close(devnull);')
        parts.append('        }')
        parts.append('')

    parts.append(f'        execv("{main_binary_name}", argv);')
    parts.append('        fprintf(stderr, "Error: execv failed: %s\\n", strerror(errno));')
    parts.append('        exit(127);')
    parts.append('    } else {')
    parts.append('        /* Parent process */')
    if suppress_debug:
        parts.append('        if (devnull >= 0) close(devnull);')
    parts.append('        int exit_code;')
    parts.append('        waitpid(pid, &status, 0);')
    parts.append('        exit_code = WIFEXITED(status) ? WEXITSTATUS(status) : 1;')
    parts.append('')
    parts.append('        /* Copy runtime-generated files back to the original')
    parts.append('         * working directory before cleaning up the temp dir. */')
    parts.append('        copy_back(tmpdir, orig_cwd, "agent_memory.json");')
    parts.append('')
    parts.append('        cleanup_files(tmpdir);')
    parts.append('        return exit_code;')
    parts.append('    }')
    parts.append('}')

    return "\n".join(parts)


def main():
    parser = argparse.ArgumentParser(
        description="Bundle Photino AOT project into single executable."
    )
    parser.add_argument("project_dir", nargs="?", default=".",
                        help="Directory containing Photino project files")
    parser.add_argument("--output", "-o", default=None,
                        help="Output executable name (default: PhotinoWrapper)")
    parser.add_argument("--binary", "-b", default="PhotinoAOT",
                        help="Name of main executable (default: PhotinoAOT)")
    parser.add_argument("--native", "-n", default="Photino.Native.so",
                        help="Name of native library (default: Photino.Native.so)")
    parser.add_argument("--wwwroot", "-w", default="wwwroot",
                        help="Name of web root directory (default: wwwroot)")
    parser.add_argument("--static", "-s", action="store_true",
                        help="Statically link wrapper")
    parser.add_argument("--keep-c", action="store_true",
                        help="Keep generated .c file")
    parser.add_argument("--suppress-debug", action="store_true",
                        help="Suppress ALL output (stdout + stderr)")

    args = parser.parse_args()
    project_dir = args.project_dir

    files = {}

    # Main binary
    binary_path = os.path.join(project_dir, args.binary)
    if not os.path.isfile(binary_path):
        print(f"Error: main binary not found: {binary_path}", file=sys.stderr)
        sys.exit(1)

    with open(binary_path, "rb") as f:
        files[args.binary] = (f.read(), 0o755)
    print(f"  {args.binary}: {len(files[args.binary][0])} bytes")

    # Native library
    native_path = os.path.join(project_dir, args.native)
    if os.path.isfile(native_path):
        with open(native_path, "rb") as f:
            files[args.native] = (f.read(), 0o644)
        print(f"  {args.native}: {len(files[args.native][0])} bytes")

    # wwwroot
    wwwroot_path = os.path.join(project_dir, args.wwwroot)
    if os.path.isdir(wwwroot_path):
        for root, dirs, filenames in os.walk(wwwroot_path):
            for fn in filenames:
                full_path = os.path.join(root, fn)
                rel_path = os.path.relpath(full_path, project_dir)
                with open(full_path, "rb") as f:
                    files[rel_path] = (f.read(), 0o644)
                print(f"  {rel_path}: {len(files[rel_path][0])} bytes")

    if not files:
        print("Error: no files to embed!", file=sys.stderr)
        sys.exit(1)

    total_size = sum(len(d) for d, _ in files.values())
    print(f"\nTotal embedded data: {total_size} bytes")

    print("\nGenerating C wrapper...")
    c_source = generate_c_wrapper(files, args.suppress_debug)

    output_name = args.output or "PhotinoWrapper"

    c_fd, c_path = tempfile.mkstemp(suffix=".c", prefix="photino_wrapper_")
    os.close(c_fd)
    with open(c_path, "w") as f:
        f.write(c_source)

    print(f"Generated C source: {len(c_source)} bytes")
    if args.suppress_debug:
        print("Output suppression: ENABLED (stdout + stderr)")

    print("Compiling...")
    compile_cmd = ["gcc", "-O2", "-s", "-o", output_name, c_path]
    if args.static:
        compile_cmd.append("-static")

    result = subprocess.run(compile_cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error: compilation failed:\n{result.stderr}", file=sys.stderr)
        os.unlink(c_path)
        sys.exit(1)

    if not args.keep_c:
        os.unlink(c_path)

    wrapper_size = os.path.getsize(output_name)
    overhead = wrapper_size - total_size
    print(f"\nOutput: {output_name} ({wrapper_size} bytes)")
    print(f"Overhead: {overhead} bytes ({overhead * 100 / total_size:.1f}%)")
    print("Done!")


if __name__ == "__main__":
    main()
