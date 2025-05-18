;; compliance-threshold.clar
;; Establishes regulatory limits for different environmental metrics

(define-data-var admin principal tx-sender)

;; Threshold data structure
(define-map thresholds
  {
    metric-type: (string-ascii 32),
    region: (string-ascii 32)
  }
  {
    max-value: int,
    min-value: int,
    updated-at: uint,
    updated-by: principal
  }
)

;; Set a new threshold
(define-public (set-threshold
                (metric-type (string-ascii 32))
                (region (string-ascii 32))
                (max-value int)
                (min-value int))
  (let ((caller tx-sender))
    (if (is-eq caller (var-get admin))
        (begin
          (map-set thresholds
            {
              metric-type: metric-type,
              region: region
            }
            {
              max-value: max-value,
              min-value: min-value,
              updated-at: block-height,
              updated-by: caller
            }
          )
          (ok true)
        )
        (err u3) ;; Not authorized
    )
  )
)

;; Get threshold information
(define-read-only (get-threshold (metric-type (string-ascii 32)) (region (string-ascii 32)))
  (map-get? thresholds { metric-type: metric-type, region: region })
)

;; Check if a value exceeds threshold
(define-read-only (is-compliant (metric-type (string-ascii 32)) (region (string-ascii 32)) (value int))
  (match (map-get? thresholds { metric-type: metric-type, region: region })
    threshold (and
                (>= value (get min-value threshold))
                (<= value (get max-value threshold))
              )
    false ;; No threshold defined, assume non-compliant
  )
)

;; Update max threshold value
(define-public (update-max-threshold
                (metric-type (string-ascii 32))
                (region (string-ascii 32))
                (max-value int))
  (let ((caller tx-sender))
    (if (is-eq caller (var-get admin))
        (match (map-get? thresholds { metric-type: metric-type, region: region })
          threshold (begin
            (map-set thresholds
              {
                metric-type: metric-type,
                region: region
              }
              (merge threshold {
                max-value: max-value,
                updated-at: block-height,
                updated-by: caller
              })
            )
            (ok true)
          )
          (err u2) ;; Threshold not found
        )
        (err u3) ;; Not authorized
    )
  )
)

;; Update min threshold value
(define-public (update-min-threshold
                (metric-type (string-ascii 32))
                (region (string-ascii 32))
                (min-value int))
  (let ((caller tx-sender))
    (if (is-eq caller (var-get admin))
        (match (map-get? thresholds { metric-type: metric-type, region: region })
          threshold (begin
            (map-set thresholds
              {
                metric-type: metric-type,
                region: region
              }
              (merge threshold {
                min-value: min-value,
                updated-at: block-height,
                updated-by: caller
              })
            )
            (ok true)
          )
          (err u2) ;; Threshold not found
        )
        (err u3) ;; Not authorized
    )
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
