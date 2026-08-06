# ROS 2 Humble on Ubuntu 22.04 (WSL2)

![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![ROS2](https://img.shields.io/badge/ROS2-Humble-22314E?style=for-the-badge&logo=ros&logoColor=white)
![WSL2](https://img.shields.io/badge/WSL2-Windows-0078D4?style=for-the-badge&logo=windows&logoColor=white)
![Status](https://img.shields.io/badge/Status-Completed-success?style=for-the-badge)

---

# 📖 Overview

This repository demonstrates the installation and verification of **ROS 2 Humble Hawksbill** on **Ubuntu 22.04 LTS** using **Windows Subsystem for Linux 2 (WSL2)**.

يوضح هذا المستودع خطوات تثبيت والتحقق من تشغيل **ROS 2 Humble Hawksbill** على **Ubuntu 22.04 LTS** باستخدام **WSL2**.

---

# 🎯 Objectives

- Install Ubuntu 22.04 using WSL2.
- تثبيت Ubuntu 22.04 باستخدام WSL2.

- Install ROS 2 Humble.
- تثبيت ROS 2 Humble.

- Configure the ROS environment.
- إعداد بيئة ROS.

- Verify the installation.
- التحقق من نجاح التثبيت.

- Test Publisher and Subscriber communication.
- اختبار التواصل بين Publisher و Subscriber.

---

# 🖥️ Environment

| Component | Version |
|-----------|----------|
| Operating System | Windows 10 |
| Linux Distribution | Ubuntu 22.04 LTS |
| Platform | WSL2 |
| ROS Version | ROS 2 Humble Hawksbill |

---

# 🛠️ Technologies

- Ubuntu 22.04 LTS
- Windows Subsystem for Linux 2 (WSL2)
- ROS 2 Humble Hawksbill
- Python
- C++
- Ubuntu Terminal

---

# 📂 Project Structure

```text
ROS2-Humble/
│
├── README.md
└── screenshots/
    ├── 1.png
    ├── 2.png
    ├── 3.png
    └── 4.png
```

---

# 🚀 Installation Process

### 1️⃣ Update Ubuntu

Update the system packages before installing ROS 2.

تحديث حزم النظام قبل تثبيت ROS 2.

```bash
sudo apt update
sudo apt upgrade -y
```

<p align="center">
<img src="screenshots/1.png" width="900">
</p>

---

### 2️⃣ Install ROS 2 Humble

Install ROS 2 Humble and configure the official repository.

تثبيت ROS 2 Humble وإعداد المستودع الرسمي.

```bash
sudo apt install ros-humble-desktop
```

<p align="center">
<img src="screenshots/3.png" width="900">
</p>

---

### 3️⃣ Configure ROS Environment

Load the ROS environment and verify the installation.

تحميل بيئة ROS والتحقق من نجاح التثبيت.

```bash
source /opt/ros/humble/setup.bash
echo $ROS_DISTRO
```

Expected output:

```text
humble
```

<p align="center">
<img src="screenshots/2.png" width="900">
</p>

---

### 4️⃣ Communication Test

Run the Publisher and Subscriber demo nodes to verify successful communication.

تشغيل عقدتي Publisher و Subscriber للتأكد من نجاح التواصل.

```bash
ros2 run demo_nodes_cpp talker
```

```bash
ros2 run demo_nodes_py listener
```

<p align="center">
<img src="screenshots/4.png" width="1000">
</p>

---

# ✅ Result

ROS 2 Humble was successfully installed and configured on Ubuntu 22.04 using WSL2.

تم تثبيت وإعداد ROS 2 Humble بنجاح على Ubuntu 22.04 باستخدام WSL2.

Communication between the Talker and Listener nodes confirmed that the ROS environment is working correctly.

أكد التواصل بين عقدتي Talker و Listener أن بيئة ROS تعمل بالشكل الصحيح.

---

# 📚 Learning Outcomes

- Ubuntu installation using WSL2.
- تثبيت Ubuntu باستخدام WSL2.

- ROS 2 installation and configuration.
- تثبيت وإعداد ROS 2.

- Running ROS nodes.
- تشغيل عقد ROS.

- Publisher and Subscriber communication.
- فهم آلية التواصل بين Publisher و Subscriber.

---

# 📄 License

This project is intended for educational purposes only.

تم إنشاء هذا المشروع للأغراض التعليمية فقط.

---

<div align="center">

### 👨‍💻 Abdulrahman Al-Rubaie

Computer Engineering Student • Robotics Enthusiast

طالب هندسة حاسب مهتم بالروبوتات وتقنيات ROS

</div>
