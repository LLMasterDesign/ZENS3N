#!/usr/bin/env python3
"""
///▙▖▙▖▞▞▙▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂
▛//▞▞ ⟦⎊⟧ :: ⧗-25.61 // NOTIFIER ▞▞
▞//▞ External Notifier :: ρ{contact}.φ{notify}.τ{external}.λ{bridge} ⫸
▙⌱📡 ≔ [⊢{event}⇨{format}⟿{send}▷{outside-world}]
〔external.notification.system〕 :: ∎

External Notification System
Contact outside world when critical events occur
"""

import os
import json
import smtplib
import requests
from pathlib import Path
from datetime import datetime
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# Config (can be loaded from file)
CONFIG_FILE = Path("!BASE.OPERATIONS/.3ox/notify_config.json")


def load_config():
    """Load notification configuration"""
    if CONFIG_FILE.exists():
        with open(CONFIG_FILE, 'r') as f:
            return json.load(f)
    else:
        # Default config
        return {
            "email": {
                "enabled": False,
                "smtp_server": "",
                "smtp_port": 587,
                "from_email": "",
                "to_email": "",
                "password": ""
            },
            "webhook": {
                "enabled": False,
                "url": "",
                "headers": {}
            },
            "file": {
                "enabled": True,  # Always log to file
                "path": "!BASE.OPERATIONS/.3ox/0ut.3ox/NOTIFICATIONS.LOG.md"
            }
        }


def notify_email(subject, message, config):
    """Send email notification"""
    if not config['email']['enabled']:
        return False
    
    try:
        msg = MIMEMultipart()
        msg['From'] = config['email']['from_email']
        msg['To'] = config['email']['to_email']
        msg['Subject'] = subject
        
        msg.attach(MIMEText(message, 'plain'))
        
        server = smtplib.SMTP(config['email']['smtp_server'], config['email']['smtp_port'])
        server.starttls()
        server.login(config['email']['from_email'], config['email']['password'])
        server.send_message(msg)
        server.quit()
        
        print(f"✓ Email sent: {subject}")
        return True
        
    except Exception as e:
        print(f"❌ Email failed: {e}")
        return False


def notify_webhook(event_type, data, config):
    """Send webhook notification"""
    if not config['webhook']['enabled']:
        return False
    
    try:
        payload = {
            "event": event_type,
            "timestamp": datetime.now().isoformat(),
            "data": data
        }
        
        response = requests.post(
            config['webhook']['url'],
            json=payload,
            headers=config['webhook']['headers'],
            timeout=10
        )
        
        if response.status_code == 200:
            print(f"✓ Webhook sent: {event_type}")
            return True
        else:
            print(f"⚠️  Webhook returned {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Webhook failed: {e}")
        return False


def notify_file(event_type, message, config):
    """Log notification to file (always enabled)"""
    log_path = Path(config['file']['path'])
    log_path.parent.mkdir(parents=True, exist_ok=True)
    
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    # Create log if doesn't exist
    if not log_path.exists():
        log_path.write_text(f"""# External Notifications Log
**Generated:** {timestamp}

---

## Notifications

""", encoding='utf-8')
    
    # Append notification
    entry = f"""
### [{timestamp}] {event_type}

{message}

---
"""
    
    with open(log_path, 'a', encoding='utf-8') as f:
        f.write(entry)
    
    print(f"✓ Logged to file: {event_type}")
    return True


def notify(event_type, message, subject=None, webhook_data=None):
    """
    Send notification via all configured channels
    
    event_type: Type of event (e.g., "CRITICAL_ERROR", "MILESTONE", "STATUS")
    message: Message body
    subject: Email subject (defaults to event_type)
    webhook_data: Additional data for webhook
    """
    config = load_config()
    
    if subject is None:
        subject = f"[Raven] {event_type}"
    
    results = {
        'email': False,
        'webhook': False,
        'file': False
    }
    
    # Try each notification method
    results['email'] = notify_email(subject, message, config)
    
    if webhook_data:
        results['webhook'] = notify_webhook(event_type, webhook_data, config)
    
    results['file'] = notify_file(event_type, message, config)
    
    return results


def notify_critical(message):
    """Quick function for critical notifications"""
    return notify("CRITICAL", message, subject="[Raven] CRITICAL ALERT")


def notify_milestone(milestone_name, details):
    """Quick function for milestone notifications"""
    message = f"""Milestone Reached: {milestone_name}

{details}
"""
    return notify("MILESTONE", message, subject=f"[Raven] Milestone: {milestone_name}")


def notify_status(status_message):
    """Quick function for status updates"""
    return notify("STATUS", status_message, subject="[Raven] Status Update")


def create_default_config():
    """Create default config file"""
    config = load_config()
    CONFIG_FILE.parent.mkdir(parents=True, exist_ok=True)
    
    with open(CONFIG_FILE, 'w') as f:
        json.dump(config, f, indent=2)
    
    print(f"✓ Created config: {CONFIG_FILE}")
    print("\nEdit this file to configure notifications:")
    print(f"  {CONFIG_FILE}")


if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1:
        command = sys.argv[1]
        
        if command == "--init":
            create_default_config()
        
        elif command == "--test":
            print("📡 Testing External Notifier\n")
            
            result = notify_status("Test notification from Raven system. All systems operational.")
            
            print(f"\nResults:")
            for method, success in result.items():
                print(f"  {method}: {'✓' if success else '❌'}")
            
            print(f"\nCheck: !BASE.OPERATIONS/.3ox/0ut.3ox/NOTIFICATIONS.LOG.md")
        
        elif command == "--critical":
            message = " ".join(sys.argv[2:]) if len(sys.argv) > 2 else "Critical event detected"
            notify_critical(message)
        
        elif command == "--milestone":
            name = sys.argv[2] if len(sys.argv) > 2 else "Unnamed Milestone"
            details = " ".join(sys.argv[3:]) if len(sys.argv) > 3 else "Milestone reached"
            notify_milestone(name, details)
        
        else:
            print("Usage:")
            print("  --init              Create default config")
            print("  --test              Test notifications")
            print("  --critical [msg]    Send critical alert")
            print("  --milestone [name] [details]  Send milestone notification")
    else:
        print("External Notification System")
        print("Run with --help for usage")

