;; sensor-data.clar
;; Records emissions and environmental metrics from verified facilities

(define-data-var admin principal tx-sender)

;; Sensor data structure
(define-map sensors
  { sensor-id: (string-ascii 32) }
  {
    facility-id: (string-ascii 32),
    metric-type: (string-ascii 32),
    active: bool,
    last-reading-time: uint
  }
)

;; Sensor readings storage
(define-map sensor-readings
  {
    sensor-id: (string-ascii 32),
    timestamp: uint
  }
  {
    value: int,
    hash: (buff 32)
  }
)

;; Register a new sensor
(define-public (register-sensor
                (sensor-id (string-ascii 32))
                (facility-id (string-ascii 32))
                (metric-type (string-ascii 32)))
  (let ((caller tx-sender))
    (if (is-eq caller (var-get admin))
        (if (map-insert sensors
                       { sensor-id: sensor-id }
                       {
                         facility-id: facility-id,
                         metric-type: metric-type,
                         active: true,
                         last-reading-time: u0
                       })
            (ok true)
            (err u1) ;; Sensor ID already exists
        )
        (err u3) ;; Not authorized
    )
  )
)

;; Record sensor data
(define-public (record-sensor-data
                (sensor-id (string-ascii 32))
                (value int)
                (data-hash (buff 32)))
  (let ((caller tx-sender)
        (timestamp block-height))
    (match (map-get? sensors { sensor-id: sensor-id })
      sensor (if (is-eq caller (var-get admin))
                (begin
                  (map-set sensor-readings
                    {
                      sensor-id: sensor-id,
                      timestamp: timestamp
                    }
                    {
                      value: value,
                      hash: data-hash
                    }
                  )
                  (map-set sensors
                    { sensor-id: sensor-id }
                    (merge sensor { last-reading-time: timestamp })
                  )
                  (ok true)
                )
                (err u3) ;; Not authorized
      )
      (err u2) ;; Sensor not found
    )
  )
)

;; Get sensor information
(define-read-only (get-sensor (sensor-id (string-ascii 32)))
  (map-get? sensors { sensor-id: sensor-id })
)

;; Get sensor reading at specific timestamp
(define-read-only (get-sensor-reading (sensor-id (string-ascii 32)) (timestamp uint))
  (map-get? sensor-readings { sensor-id: sensor-id, timestamp: timestamp })
)

;; Deactivate a sensor
(define-public (deactivate-sensor (sensor-id (string-ascii 32)))
  (let ((caller tx-sender))
    (if (is-eq caller (var-get admin))
        (match (map-get? sensors { sensor-id: sensor-id })
          sensor (begin
            (map-set sensors
              { sensor-id: sensor-id }
              (merge sensor { active: false })
            )
            (ok true)
          )
          (err u2) ;; Sensor not found
        )
        (err u3) ;; Not authorized
    )
  )
)

;; Reactivate a sensor
(define-public (reactivate-sensor (sensor-id (string-ascii 32)))
  (let ((caller tx-sender))
    (if (is-eq caller (var-get admin))
        (match (map-get? sensors { sensor-id: sensor-id })
          sensor (begin
            (map-set sensors
              { sensor-id: sensor-id }
              (merge sensor { active: true })
            )
            (ok true)
          )
          (err u2) ;; Sensor not found
        )
        (err u3) ;; Not authorized
    )
  )
)

;; Verify data integrity
(define-read-only (verify-data-integrity
                   (sensor-id (string-ascii 32))
                   (timestamp uint)
                   (expected-hash (buff 32)))
  (match (map-get? sensor-readings { sensor-id: sensor-id, timestamp: timestamp })
    reading (is-eq (get hash reading) expected-hash)
    false
  )
)
