Got it. You want a **production-ready README.md** that you can ship with your ISO, so clients (or even you, if you rebuild later) have a bulletproof set of steps to configure the 200 GB disk for Docker, relocate Docker’s root, and avoid the 4 GB overlay trap.

Here’s a draft README.md for you:

---

# 🐧 Docker Disk Setup for MySoftware ISO

This guide explains how to prepare the **200 GB secondary disk (`/dev/sda`)** for Docker, so that containers (Zabbix, MySQL, etc.) won’t hit the 4 GB overlay limit inside the ISO environment.

By default, Docker writes to the root filesystem (`/var/lib/docker`).
Since Penguin’s Eggs ISOs boot into an overlay (`/`), space is limited.
We fix this by mounting the real 200 GB disk at `/mnt/docker` and telling Docker to use it as its root.

---

## 1. Partition the Disk

⚠️ Warning: This will erase **all data** on `/dev/sda`.

```bash
sudo parted /dev/sda -- mklabel gpt
sudo parted -a opt /dev/sda -- mkpart primary ext4 0% 100%
```

---

## 2. Format the Partition

```bash
sudo mkfs.ext4 /dev/sda1 -L dockerdata
```

---

## 3. Mount the Disk

```bash
sudo mkdir -p /mnt/docker
sudo mount /dev/sda1 /mnt/docker
```

Verify:

```bash
df -h /mnt/docker
```

You should see \~200 GB free.

---

## 4. Make Mount Permanent

Edit `/etc/fstab` and add:

```
LABEL=dockerdata   /mnt/docker   ext4   defaults   0   2
```

Test with:

```bash
sudo mount -a
```

---

## 5. Configure Docker Root

Edit `/etc/docker/daemon.json`:

```json
{
  "data-root": "/mnt/docker",
  "dns": ["8.8.8.8", "8.8.4.4"]
}
```

---

## 6. Restart Docker

```bash
sudo systemctl stop docker
sudo rm -rf /mnt/docker/*    # Clear stale root
sudo systemctl start docker
```

Confirm:

```bash
docker info | grep "Docker Root Dir"
```

It should show:

```
Docker Root Dir: /mnt/docker
```

---

## 7. Verify Images and Space

Pull images:

```bash
docker compose up
```

Check space:

```bash
df -h /mnt/docker
```

---

## 8. Notes for Clients (ISO Users)

* This setup must be done **once after installation from ISO**.
* Without it, Docker will default to the overlay filesystem (`/var/lib/docker`) and run out of space.
* After configuration, Docker will have full access to the 200 GB disk.
* If you ship the ISO with this README, clients will be able to set up their disk correctly.

---

✅ After this, your system will use the real 200 GB disk for all containers and volumes.

---

Do you want me to extend this README with a **“Penguin’s Eggs ISO build section”**, so that *your* build process (with `eggs produce --clone`) automatically includes these configs (`/etc/fstab` + `daemon.json`), so clients don’t even need to touch them?
