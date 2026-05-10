# Cache

```sh
nvme0n1     259:0    0 465.8G  0 disk
└─nvme0n1p1 259:1    0 465.8G  0 part /mnt/nvme
```

in my case, I want use my disk as cache for `Cargo` and `Podman`

## Setup Disk

## XFS

`XFS` is a high-performance, 64-bit journaling filesystem designed for:

- large files
- parallel I/O
- high-throughput storage

```bash
sudo mkfs.xfs -d agcount=64 -f -s size=4096 /dev/nvme0n1p1
```

### `-d agcount=64`

### **Allocation Groups (AGs)**

`XFS` devides the filesystem into **Allocation Groups**:

- each AG is like an independent "mini-filesystem"
- they allow **parallel allocation and I/O**
- reduce contention on multi-core systems

```bash
Disk →
  AG0 | AG1 | AG2 | ... | AG63
```
