(define-non-fungible-token skill-certificate uint)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u101))
(define-constant err-certificate-not-found (err u102))
(define-constant err-already-exists (err u103))
(define-constant err-invalid-recipient (err u104))
(define-constant err-not-certificate-owner (err u105))
(define-constant err-instructor-not-registered (err u106))

(define-data-var last-certificate-id uint u0)

(define-map certificates
  uint
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
)

(define-map instructors
  principal
  {
    name: (string-ascii 100),
    institution: (string-ascii 100),
    verified: bool,
    registration-date: uint,
    total-certificates-issued: uint
  }
)

(define-map student-certificates
  principal
  (list 50 uint)
)

(define-map institution-stats
  (string-ascii 100)
  {
    total-certificates: uint,
    total-instructors: uint,
    verified-institution: bool
  }
)

(define-map skill-statistics
  (string-ascii 100)
  {
    total-issued: uint,
    unique-recipients: uint
  }
)

(define-public (register-instructor (name (string-ascii 100)) (institution (string-ascii 100)))
  (let
    (
      (caller tx-sender)
      (current-block stacks-block-height)
    )
    (asserts! (is-none (map-get? instructors caller)) err-already-exists)
    (map-set instructors caller
      {
        name: name,
        institution: institution,
        verified: false,
        registration-date: current-block,
        total-certificates-issued: u0
      }
    )
    (map-set institution-stats institution
      (match (map-get? institution-stats institution)
        existing-stats (merge existing-stats { total-instructors: (+ (get total-instructors existing-stats) u1) })
        { total-certificates: u0, total-instructors: u1, verified-institution: false }
      )
    )
    (ok true)
  )
)

(define-public (verify-instructor (instructor principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (match (map-get? instructors instructor)
      instructor-data
        (begin
          (map-set instructors instructor (merge instructor-data { verified: true }))
          (ok true)
        )
      err-not-authorized
    )
  )
)

(define-public (verify-institution (institution (string-ascii 100)))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (match (map-get? institution-stats institution)
      stats
        (begin
          (map-set institution-stats institution (merge stats { verified-institution: true }))
          (ok true)
        )
      err-not-authorized
    )
  )
)

(define-public (issue-certificate 
  (recipient principal)
  (skill-name (string-ascii 100))
  (description (string-ascii 500))
  (skill-level (string-ascii 20))
  (expiry-date (optional uint))
  (verification-hash (buff 32))
)
  (let
    (
      (issuer tx-sender)
      (certificate-id (+ (var-get last-certificate-id) u1))
      (current-block stacks-block-height)
    )
    (match (map-get? instructors issuer)
      instructor-data
        (begin
          (asserts! (get verified instructor-data) err-not-authorized)
          (asserts! (not (is-eq recipient issuer)) err-invalid-recipient)
          
          (try! (nft-mint? skill-certificate certificate-id recipient))
          
          (map-set certificates certificate-id
            {
              skill-name: skill-name,
              description: description,
              issuer: issuer,
              recipient: recipient,
              issued-at: current-block,
              expiry-date: expiry-date,
              skill-level: skill-level,
              institution: (get institution instructor-data),
              verification-hash: verification-hash
            }
          )
          
          (map-set instructors issuer
            (merge instructor-data 
              { total-certificates-issued: (+ (get total-certificates-issued instructor-data) u1) }
            )
          )
          
          (map-set student-certificates recipient
            (match (map-get? student-certificates recipient)
              existing-certs (unwrap-panic (as-max-len? (append existing-certs certificate-id) u50))
              (list certificate-id)
            )
          )
          
          (map-set institution-stats (get institution instructor-data)
            (match (map-get? institution-stats (get institution instructor-data))
              existing-stats (merge existing-stats { total-certificates: (+ (get total-certificates existing-stats) u1) })
              { total-certificates: u1, total-instructors: u1, verified-institution: false }
            )
          )
          
          (map-set skill-statistics skill-name
            (match (map-get? skill-statistics skill-name)
              existing-skill (merge existing-skill { total-issued: (+ (get total-issued existing-skill) u1) })
              { total-issued: u1, unique-recipients: u1 }
            )
          )
          
          (var-set last-certificate-id certificate-id)
          (ok certificate-id)
        )
      err-instructor-not-registered
    )
  )
)

(define-public (transfer (certificate-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-authorized)
    (try! (nft-transfer? skill-certificate certificate-id sender recipient))
    (match (map-get? certificates certificate-id)
      cert-data
        (begin
          (map-set certificates certificate-id (merge cert-data { recipient: recipient }))
          (ok true)
        )
      err-certificate-not-found
    )
  )
)

(define-read-only (get-last-certificate-id)
  (ok (var-get last-certificate-id))
)

(define-read-only (get-certificate-uri (certificate-id uint))
  (ok (some "https://certificates.skillchain.io/"))
)

(define-read-only (get-owner (certificate-id uint))
  (ok (nft-get-owner? skill-certificate certificate-id))
)

(define-read-only (get-certificate (certificate-id uint))
  (ok (map-get? certificates certificate-id))
)

(define-read-only (get-instructor (instructor principal))
  (ok (map-get? instructors instructor))
)

(define-read-only (get-student-certificates (student principal))
  (ok (map-get? student-certificates student))
)

(define-read-only (get-institution-stats (institution (string-ascii 100)))
  (ok (map-get? institution-stats institution))
)

(define-read-only (get-skill-stats (skill (string-ascii 100)))
  (ok (map-get? skill-statistics skill))
)

(define-read-only (verify-certificate (certificate-id uint) (verification-hash (buff 32)))
  (match (map-get? certificates certificate-id)
    cert-data
      (ok (is-eq (get verification-hash cert-data) verification-hash))
    (ok false)
  )
)

(define-read-only (is-certificate-valid (certificate-id uint))
  (match (map-get? certificates certificate-id)
    cert-data
      (match (get expiry-date cert-data)
        expiry (ok (> expiry stacks-block-height))
        (ok true)
      )
    (ok false)
  )
)

(define-read-only (check-certificate-skill (certificate-id uint) (skill-name (string-ascii 100)))
  (match (map-get? certificates certificate-id)
    cert-data (ok (is-eq (get skill-name cert-data) skill-name))
    (ok false)
  )
)

(define-read-only (check-certificate-institution (certificate-id uint) (institution (string-ascii 100)))
  (match (map-get? certificates certificate-id)
    cert-data (ok (is-eq (get institution cert-data) institution))
    (ok false)
  )
)

(define-read-only (get-total-certificates)
  (ok (var-get last-certificate-id))
)

(define-read-only (is-instructor-verified (instructor principal))
  (match (map-get? instructors instructor)
    instructor-data (ok (get verified instructor-data))
    (ok false)
  )
)
