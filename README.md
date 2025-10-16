# 🎓 Decentralized Skill Certificate Platform

## 📋 Overview

A blockchain-based platform for issuing, managing, and verifying skill certificates as NFTs. Instructors and educational institutions can issue verifiable digital certificates that serve as tamper-proof credentials for students' portfolios and digital resumes.

## ✨ Features

- 🏫 **Instructor Registration**: Educational institutions and instructors can register and get verified
- 📜 **NFT Certificates**: Issue skill certificates as unique NFTs with metadata
- ✅ **Verification System**: Cryptographic verification of certificate authenticity
- 📊 **Analytics**: Track statistics for skills, institutions, and certificate issuance
- 🔄 **Transferable**: Certificates can be transferred between addresses
- ⏰ **Expiry Management**: Optional expiry dates for time-sensitive certifications
- 🌐 **Institution Stats**: Track performance metrics for educational institutions

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Basic understanding of Clarity smart contracts

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd Decentralized-Skill-Certificate-Platform
```

2. Install dependencies
```bash
clarinet install
```

3. Run tests
```bash
clarinet test
```

## 🔧 Smart Contract Functions

### 📝 Public Functions

#### `register-instructor`
Register as an instructor or educational institution.
```clarity
(register-instructor "John Smith" "MIT OpenCourseWare")
```

#### `issue-certificate`
Issue a skill certificate to a student (requires verified instructor status).
```clarity
(issue-certificate 
  'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR  ; recipient
  "Advanced JavaScript"                           ; skill-name
  "Completed advanced JS programming course"      ; description
  "Advanced"                                      ; skill-level
  (some u1000000)                                ; expiry-date (optional)
  0x1234567890abcdef                             ; verification-hash
)
```

#### `verify-instructor`
Verify an instructor (contract owner only).
```clarity
(verify-instructor 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR)
```

#### `transfer`
Transfer certificate ownership.
```clarity
(transfer u1 tx-sender 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR)
```

### 🔍 Read-Only Functions

#### `get-certificate`
Retrieve certificate details by ID.
```clarity
(get-certificate u1)
```

#### `get-student-certificates`
Get all certificates owned by a student.
```clarity
(get-student-certificates 'SP2C2YFP12AJZB4MABJBAJ55XECVS7E4PMMZ89YZR)
```

#### `verify-certificate`
Verify certificate authenticity using verification hash.
```clarity
(verify-certificate u1 0x1234567890abcdef)
```

#### `is-certificate-valid`
Check if certificate is still valid (not expired).
```clarity
(is-certificate-valid u1)
```

#### `get-institution-stats`
Get statistics for an educational institution.
```clarity
(get-institution-stats "MIT OpenCourseWare")
```

## 📊 Data Structures

### Certificate Schema
```clarity
{
  skill-name: (string-ascii 100),
  description: (string-ascii 500),
  issuer: principal,
  recipient: principal,
  issued-at: uint,
  expiry-date: (optional uint),
  skill-level: (string-ascii 20),
  institution: (string-ascii 100),
  verification-hash: (buff 32)
}
```

### Instructor Schema
```clarity
{
  name: (string-ascii 100),
  institution: (string-ascii 100),
  verified: bool,
  registration-date: uint,
  total-certificates-issued: uint
}
```

## 🎯 Usage Examples

### For Educational Institutions

1. **Register as an instructor**
```clarity
(contract-call? .skill-certificate register-instructor "Dr. Jane Doe" "Stanford University")
```

2. **Wait for verification from platform admin**

3. **Issue certificates to students**
```clarity
(contract-call? .skill-certificate issue-certificate 
  'ST1STUDENT123... 
  "Machine Learning Fundamentals" 
  "Completed 12-week intensive ML course with hands-on projects"
  "Intermediate"
  none
  0xabcdef1234567890...)
```

### For Students

1. **View your certificates**
```clarity
(contract-call? .skill-certificate get-student-certificates tx-sender)
```

2. **Verify a certificate's authenticity**
```clarity
(contract-call? .skill-certificate verify-certificate u1 0xabcdef1234567890...)
```

3. **Check certificate validity**
```clarity
(contract-call? .skill-certificate is-certificate-valid u1)
```

### For Employers/Verifiers

1. **Verify candidate's certificate**
```clarity
(contract-call? .skill-certificate get-certificate u1)
(contract-call? .skill-certificate verify-certificate u1 <provided-hash>)
```

2. **Check institution credibility**
```clarity
(contract-call? .skill-certificate get-institution-stats "Stanford University")
```

## 🔐 Security Features

- ✅ **Only verified instructors** can issue certificates
- 🔒 **Cryptographic verification** prevents certificate forgery  
- 👤 **Owner-only functions** for critical admin operations
- 🛡️ **Input validation** prevents malicious data insertion
- 📱 **NFT compliance** ensures standard compatibility

## 🌟 Benefits

- 🚫 **Tamper-proof**: Blockchain immutability prevents certificate fraud
- 🌍 **Global verification**: Anyone can verify certificates worldwide
- 💰 **Cost-effective**: Reduces paperwork and verification costs
- ⚡ **Instant verification**: Real-time certificate validation
- 📈 **Portfolio building**: Students build verifiable skill portfolios
- 🏢 **Employer confidence**: Recruiters trust blockchain-verified skills

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For questions or support, please open an issue on GitHub or contact the development team.

---

*Built with ❤️ for the future of education and skill verification*
