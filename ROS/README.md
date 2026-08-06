# ROS 2 Humble on Ubuntu 22.04 (WSL2)

![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-E95420?logo=ubuntu&logoColor=white)
![ROS2](https://img.shields.io/badge/ROS2-Humble-22314E?logo=ros&logoColor=white)
![WSL2](https://img.shields.io/badge/WSL-2-4D4D4D?logo=windows-terminal&logoColor=white)
![Status](https://img.shields.io/badge/Status-Completed-success)

---

## 📖 Project Overview | نظرة عامة

This project demonstrates the installation and verification of **ROS 2 Humble Hawksbill** on **Ubuntu 22.04 LTS** using **Windows Subsystem for Linux (WSL2)**.

يوضح هذا المشروع خطوات تثبيت والتحقق من تشغيل **ROS 2 Humble Hawksbill** على **Ubuntu 22.04 LTS** باستخدام **WSL2** على نظام Windows.

---

## 🎯 Project Objective | هدف المشروع

- Install Ubuntu 22.04 using WSL2.
- تثبيت Ubuntu 22.04 باستخدام WSL2.

- Install ROS 2 Humble.
- تثبيت ROS 2 Humble.

- Verify successful installation using the official ROS 2 demo nodes.
- التحقق من نجاح التثبيت باستخدام العقد التجريبية الرسمية.

---

## ✨ Features | المميزات

- Ubuntu 22.04 LTS Environment.
- بيئة Ubuntu 22.04 LTS.

- ROS 2 Humble Installation.
- تثبيت ROS 2 Humble.

- Demo Nodes Verification.
- اختبار العقد التجريبية.

- Publisher / Subscriber Communication.
- اختبار التواصل بين الناشر والمشترك.

- WSL2 Integration.
- التشغيل باستخدام WSL2.

---

## 🛠 Technologies Used | التقنيات المستخدمة

- Ubuntu 22.04 LTS
- Windows Subsystem for Linux 2 (WSL2)
- ROS 2 Humble Hawksbill
- C++
- Python
- Ubuntu Terminal

---

## 📂 Project Structure | هيكل المشروع

```text
ROS2-Humble/
│
├── README.md
├── screenshots/
│   ├── ubuntu-install.png
│   ├── ros-environment.png
│   ├── talker.png
│   ├── listener.png
│   └── communication.png
│
└── docs/
    └── installation-notes.md
```

---

## 🚀 Verification | التحقق من التثبيت

Check the installed ROS distribution:

```bash
echo $ROS_DISTRO
```

Expected Output:

```text
humble
```

Run the Publisher:

```bash
ros2 run demo_nodes_cpp talker
```

Run the Subscriber:

```bash
ros2 run demo_nodes_py listener
```

Successful communication confirms that the ROS 2 environment is working correctly.

يؤكد تبادل الرسائل بين العقدتين نجاح عملية التثبيت وعمل بيئة ROS 2 بشكل صحيح.

---

## 📸 Screenshots | لقطات الشاشة

- Ubuntu 22.04 Installation
- ROS 2 Environment
- Talker Node
- Listener Node
- Publisher / Subscriber Communication

---

## 📚 Learning Outcomes | ما تم تعلمه

- Installing Ubuntu using WSL2.
- تثبيت Ubuntu باستخدام WSL2.

- Installing and configuring ROS 2 Humble.
- تثبيت وإعداد ROS 2 Humble.

- Running ROS 2 demo applications.
- تشغيل التطبيقات التجريبية.

- Understanding Publisher and Subscriber communication.
- فهم آلية التواصل بين Publisher و Subscriber.

---

## 📄 License | الترخيص

This project is created for educational purposes.

تم إنشاء هذا المشروع لأغراض تعليمية فقط.

---

Developed by **Abdulrahman Al-Rubaie** © 2026
