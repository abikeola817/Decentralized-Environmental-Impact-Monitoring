;; reporting.clar
;; Generates authenticated environmental disclosures

(define-data-var admin principal tx-sender)
(define-data-var report-counter uint u0)

;; Report data structure
(define-map reports
  { report-id: uint }
  {
    facility-id: (string-ascii 32),
    start-time: uint,
    end-time: uint,
    metrics: (list 10 (string-ascii 32)),
    data-hash: (buff 32),
    timestamp: uint,
    verified: bool,
    verifier: (optional principal)
  }
)

;; Generate a new report
(define-public (generate-report
                (facility-id (string-ascii 32))
                (start-time uint)
                (end-time uint)
                (metrics (list 10 (string-ascii 32)))
                (data-hash (buff 32)))
  (let ((caller tx-sender)
        (report-id (var-get report-counter)))
    (if (is-eq caller (var-get admin))
        (begin
          (map-insert reports
            { report-id: report-id }
            {
              facility-id: facility-id,
              start-time: start-time,
              end-time: end-time,
              metrics: metrics,
              data-hash: data-hash,
              timestamp: block-height,
              verified: false,
              verifier: none
            }
          )
          (var-set report-counter (+ report-id u1))
          (ok report-id)
        )
        (err u3) ;; Not authorized
    )
  )
)

;; Verify a report
(define-public (verify-report (report-id uint))
  (let ((caller tx-sender))
    (if (is-eq caller (var-get admin))
        (match (map-get? reports { report-id: report-id })
          report (if (get verified report)
                    (err u4) ;; Already verified
                    (begin
                      (map-set reports
                        { report-id: report-id }
                        (merge report {
                          verified: true,
                          verifier: (some caller)
                        })
                      )
                      (ok true)
                    )
          )
          (err u2) ;; Report not found
        )
        (err u3) ;; Not authorized
    )
  )
)

;; Get report information
(define-read-only (get-report (report-id uint))
  (map-get? reports { report-id: report-id })
)

;; Check if report is verified
(define-read-only (is-report-verified (report-id uint))
  (match (map-get? reports { report-id: report-id })
    report (get verified report)
    false
  )
)

;; Verify report data integrity
(define-read-only (verify-report-integrity (report-id uint) (expected-hash (buff 32)))
  (match (map-get? reports { report-id: report-id })
    report (is-eq (get data-hash report) expected-hash)
    false
  )
)

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (let ((caller tx-sender))
    (if (is-eq caller (var-get admin))
        (begin
          (var-set admin new-admin)
          (ok true)
        )
        (err u3) ;; Not authorized
    )
  )
)
