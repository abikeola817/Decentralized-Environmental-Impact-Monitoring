# Decentralized Environmental Impact Monitoring

A blockchain-based system for transparent, tamper-proof environmental impact monitoring and compliance verification using Clarity smart contracts on the Stacks blockchain.

## Overview

This project implements a decentralized solution for monitoring and verifying environmental impacts from industrial facilities. By leveraging blockchain technology, it creates an immutable record of emissions data, regulatory compliance, and environmental disclosures that can be trusted by all stakeholders.

## System Architecture

The system consists of five interconnected Clarity smart contracts:

1. **Facility Verification Contract**: Validates and registers industrial sites
2. **Sensor Data Contract**: Records emissions and environmental metrics from authorized sensors
3. **Compliance Threshold Contract**: Establishes and maintains regulatory limits
4. **Alert Management Contract**: Monitors data and triggers notifications when violations occur
5. **Reporting Contract**: Generates authenticated environmental disclosure reports

![System Architecture](./docs/architecture.png)

## Smart Contracts

### Facility Verification Contract

Manages the registration and verification of industrial facilities:
- Facility registration with metadata (location, type, owner)
- Verification process by authorized entities
- Management of facility status (pending, verified, suspended)

### Sensor Data Contract

Handles the secure recording of environmental metrics:
- Registration of authorized sensor devices
- Secure data submission with timestamps
- Data validation and storage
- Historical data access

### Compliance Threshold Contract

Establishes the regulatory framework:
- Definition of compliance parameters and thresholds
- Support for different metrics and facility types
- Version control for regulatory updates
- Threshold lookup functionality

### Alert Management Contract

Manages the notification system for compliance violations:
- Automated monitoring against thresholds
- Alert generation and classification
- Notification routing to relevant stakeholders
- Alert status tracking and resolution

### Reporting Contract

Generates verifiable environmental reports:
- Aggregation of sensor data over reporting periods
- Compliance status verification
- Report authentication and timestamping
- Public disclosure mechanisms

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) for local Clarity development
- Node.js and npm for testing environment

### Installation

1. Clone the repository:
