# Outil PowerShell interactif — Technicien Support IT

Ce projet contient un **outil PowerShell interactif** conçu pour faciliter le travail d’un technicien support / helpdesk.  
Il permet d’exécuter rapidement des actions de diagnostic et de maintenance directement depuis un menu simple.

---

## 🎯 Fonctions disponibles

L'outil propose les actions suivantes :

1. 🔍 Afficher les informations système  
2. 🌐 Tester la connectivité réseau (ping + port 443)  
3. 📡 Tester la résolution DNS + HTTPS  
4. 🧹 Nettoyer les fichiers temporaires Windows  
5. 🔑 Réinitialiser un mot de passe Active Directory  
   *(uniquement si le module AD est disponible — RSAT ou un serveur)*

---

## 📂 Fichiers du dépôt
```
powershell-support-tool/
│
├── README.md
└── support-tool.ps1
```

- **README.md** → documentation du projet  
- **support-tool.ps1** → script principal contenant le menu interactif

---

## ▶️ Utilisation

### 1️⃣ Télécharger ou cloner le dépôt

```powershell
git clone https://github.com/erti-it-tech/powershell-support-tool
```

### 2️⃣ Ouvrir PowerShell en tant qu’administrateur

### 3️⃣ Exécuter le script
```powershell
cd powershell-support-tool
.\support-tool.ps1
```

---

## 🧰 Technologies utilisées

- PowerShell 5 / 7

- Cmdlets système (Get-NetIPAddress, Get-CimInstance…)

- Test-NetConnection

- Remove-Item (nettoyage)

- Module ActiveDirectory (optionnel)
  
---

## 🎓 Objectif pédagogique

Ce projet démontre :

- la capacité à automatiser les tâches d’un technicien support

- une bonne aisance avec PowerShell

- une compréhension des tests réseau et système

- une capacité à documenter clairement

Ce projet complète parfaitement les autres dépôts GitHub (Active Directory, réseau, Outlook).

---

## 👨‍💻 Auteur
Erti — technicien en informatique en reconversion professionnelle  
GitHub : https://github.com/erti-it-tech

