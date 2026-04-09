# 🚀 Gemma 4 (31B) on Jetson Thor

Run **Gemma 4 31B** locally on **Jetson Thor** using NVIDIA’s optimized `llama.cpp` container — with a simple one-command setup and a clean Web UI.

---

## 🧠 Overview

This repo provides a plug-and-play setup to:

* Run **Gemma 4 31B (GGUF)** using NVIDIA’s Jetson-optimized runtime
* Serve it via **llama.cpp OpenAI-compatible API**
* Interact through **Open WebUI**

---

## ⚙️ Current Setup (My Environment)

* Device: **Jetson Thor AGX**
* Connection: **SSH over USB-C (host → Thor)**
* Runtime: **Docker + NVIDIA Container Runtime**
* Model: **Gemma 4 31B (Q4_K_M quantization)**
* UI: **Open WebUI (local browser)**

> 💡 This setup allows you to control the Thor entirely from your host machine while running inference on-device.

---

## 🧰 Requirements

* Jetson Thor
* Docker installed
* NVIDIA Container Runtime enabled
* Stable internet (for first-time model download)

---

## ⬇️ Get the Code

```bash
git clone git@github.com:vaishkarni/Gemma4_31B_Thor.git
cd Gemma4_31B_Thor
```

---

## ⚡ Quick Start

```bash
chmod +x setup_gemma4_31b_thor.sh
./setup_gemma4_31b_thor.sh
```

---

## 🌐 Access

Once everything is running:

* **Open WebUI:** [http://localhost:3000](http://localhost:3000)

---

## ⚠️ Model Not Showing in Open WebUI?

If WebUI opens but **Gemma 4 is missing**, you need to manually connect the backend.

### 🔧 Fix

1. Open WebUI
2. Click **Profile (bottom-left)** → **Admin Panel**
3. Go to **Settings → Connections**
4. Under **OpenAI API**, click **+** and add:

```
URL: http://127.0.0.1:8080/v1
API Key: none
```

5. Click **Save**

---

### ✅ Final Step

* Return to chat
* Use the **model selector (top bar)**
* Select **Gemma 4** 🎉

---

## 🧠 Architecture

```
Jetson Thor
 ├── llama.cpp server (Gemma 4)
 │     └── OpenAI-compatible API (:8080)
 └── Open WebUI
       └── Connects via OpenAI API
```

---

## 🧪 Notes

* First run will **download the model** → may take time
* Uses **GGUF quantized weights (Q4_K_M)** for efficiency
* Optimized for **edge AI / physical AI workflows**

---
