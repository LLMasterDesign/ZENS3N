# 🔐 .3OX Registration System

**Critical Security Requirement**  
All .3ox folders MUST register and receive cryptographic keys before tx/rx operations.

---

## 🚀 Quick Start

### For New .3ox Folder Requesters:

```bash
# Step 1: Copy registration template
cp REQUESTS/TEMPLATE.registration.request.yaml \
   REQUESTS/YOURPROJECT.registration.request.yaml

# Step 2: Fill in all [PLACEHOLDER] values in the file

# Step 3: Submit to CMD.BRIDGE
# Email to: cmd.operator@3ox.ai
# Or place in: OPS/BASE.CMD/REGISTRY/REQUESTS/

# Step 4: Wait for approval and registration package

# Step 5: Follow installation instructions in package

# Step 6: Complete handshake protocol

# Step 7: Start transmitting (now authorized!)
```

### For CMD.BRIDGE Operators:

```bash
# Review pending requests in REQUESTS/ folder

# Generate registration package:
python generate_registration.py --request REQUESTS/NEWSTATION.registration.request.yaml

# Send package to requester via secure channel

# Issue challenge when ready:
python register_handshake.py --cmd --challenge NEWSTATION.BASE

# Wait for station response...

# Verify and activate:
python register_handshake.py --cmd --verify NEWSTATION.BASE
```

---

## 📁 Folder Structure

```
REGISTRY/
├── README.md                          ← You are here
├── .3OX.REGISTRATION.SYSTEM.md        ← Full documentation
├── STATION.REGISTRY.yaml              ← Master registry
│
├── generate_registration.py           ← Key generation script
├── register_handshake.py              ← Handshake protocol
├── requirements.txt                   ← Python dependencies
│
├── REQUESTS/                          ← Registration requests
│   ├── TEMPLATE.registration.request.yaml
│   └── [Pending requests...]
│
├── PACKAGES/                          ← Generated packages (CONFIDENTIAL)
│   └── [ENTITY].registration.package.yaml
│
├── KEYS/                              ← Public keys
│   ├── RVNx.BASE.pub
│   ├── SYNTH.BASE.pub
│   └── [Entity public keys...]
│
├── HANDSHAKES/                        ← Active handshakes
│   └── [Temporary challenge/response files]
│
└── AUDIT/                             ← Security logs
    ├── registrations.log
    ├── handshakes.log
    └── security_events.log
```

---

## ⚠️ CRITICAL SECURITY RULES

1. **NO .3OX FOLDER CAN TX/RX WITHOUT REGISTRATION**
2. **ALL PRIVATE KEYS MUST BE PROTECTED (IDENTITY.key)**
3. **UPLOAD LINKS ARE ONE-TIME USE ONLY**
4. **HANDSHAKE REQUIRED BEFORE ACTIVATION**
5. **KEYS EXPIRE AFTER 1 YEAR - RENEWAL REQUIRED**

---

## 📚 Documentation

- **`.3OX.REGISTRATION.SYSTEM.md`** - Complete system documentation
- **`SECURITY.AUDIT.REPORT.md`** - Vulnerability assessment

---

## 🔗 Related Systems

- **`OPS/OPS.SECURITY.ARCHITECTURE.md`** - Overall security design
- **`OPS/STATIONS/OPERATORS/TRANSACTION.SECURITY.md`** - Transaction security

---

**Last Updated:** ⧗-25.61  
**Authority:** BASE.CMD Registry  
**Status:** CRITICAL SECURITY SYSTEM



