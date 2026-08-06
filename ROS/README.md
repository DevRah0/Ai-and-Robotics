# ROS 2 Humble Installation on Ubuntu 22.04 (WSL2)

## 📌 Overview

This repository documents the installation and verification of **ROS 2 Humble Hawksbill** on **Ubuntu 22.04 LTS** running through **Windows Subsystem for Linux 2 (WSL2)**.

The installation was successfully verified using the official ROS 2 demo nodes (`talker` and `listener`).

---

## 🖥️ Environment

| Component | Version |
|----------|---------|
| Operating System | Windows 10 |
| Linux Distribution | Ubuntu 22.04 LTS |
| Platform | WSL2 |
| ROS Version | ROS 2 Humble Hawksbill |

---

## 🚀 Installation

Update the system:

```bash
sudo apt update
sudo apt upgrade -y
```

Install ROS 2 Humble by following the official ROS 2 installation guide.

Source the ROS environment:

```bash
source /opt/ros/humble/setup.bash
```

Verify the installation:

```bash
echo $ROS_DISTRO
```

Expected output:

```text
humble
```

---

## ✅ Verification

Run the Talker node:

```bash
ros2 run demo_nodes_cpp talker
```

Open another terminal and run the Listener node:

```bash
ros2 run demo_nodes_py listener
```

If the installation is successful, the Listener will receive messages similar to:

```text
I heard: [Hello World: 1]
I heard: [Hello World: 2]
...
```

---

## 📷 Screenshots

Screenshots demonstrating:

- Ubuntu 22.04 installation
- ROS 2 Humble environment
- Talker node
- Listener node
- Successful communication between nodes

---

## 📚 Technologies Used

- Ubuntu 22.04 LTS
- WSL2
- ROS 2 Humble
- C++
- Python

---

## 🎯 Result

ROS 2 Humble was successfully installed and configured on Ubuntu 22.04 running under WSL2. Communication between the Talker and Listener demo nodes confirmed that the installation and environment setup were completed successfully.

---

## 📄 License

This repository is created for educational purposes.
