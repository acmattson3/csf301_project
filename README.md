# csf301_project
Writing malloc() with mmap and brk

[Technical Blog Post](https://www.andrew-mattson.com/home/projects/coding/csf301_project)

## malloc_brk.S:
Includes a wrapper around the brk system function to allocate some bytes and a function to test them out.
- Does not implement free.
- Does not accept input.

## malloc_mmap.S:
Includes a wrapper around the mmap system function to allocate some bytes and a function to test them out.
- Does not implement free.
- Does not accept input.
