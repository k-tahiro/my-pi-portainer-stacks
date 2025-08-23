# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This repository contains Docker Compose stack configurations for Portainer deployment on DietPi (Raspberry Pi). Each directory represents a separate service stack that can be deployed through Portainer.

## Architecture

### Service Stack Structure
- Each service is organized in its own directory (e.g., `homebridge/`, `wirehole/`, `wg-easy/`)
- Each directory contains a `compose.yaml` file defining the Docker Compose configuration
- Services reference a shared `../stack.env` environment file (located at repository root)
- Some services include additional configuration files (e.g., `wirehole/unbound/unbound.conf`)

### Key Service Categories
1. **Network Services**: `wirehole/` (WireGuard + Pi-hole + Unbound DNS), `wg-easy/` (WireGuard VPN)
2. **Media/Gaming**: `restreamer/` (streaming), `moonlight-tv/` (game streaming), `minecraft-server/`  
3. **Home Automation**: `homebridge/` (HomeKit bridge)
4. **AI Services**: `open-webui/` (web UI), `open-hands/` (AI development environment)

### Network Configuration
- Complex services use custom Docker networks with static IP assignments
- `wirehole/` uses 10.2.0.0/24 subnet (Unbound: 10.2.0.200, Pi-hole: 10.2.0.100)
- `wg-easy/` uses 10.8.1.0/24 subnet (WG-Easy: 10.8.1.2, Pi-hole: 10.8.1.3)
- Several services use `network_mode: host` for direct network access

## Environment Configuration

### Stack Environment File
- Services reference `../stack.env` (should exist at repository root)
- Contains shared configuration for timezone (Asia/Tokyo), user IDs (PUID=1000, PGID=1000)
- Includes service-specific settings for WireGuard, Pi-hole, and other components
- Reference `wirehole/.env.example` for expected environment variables

### Service-Specific Environment
- Individual services may have local `.env` files
- Current local env files: `wg-easy/.env`, `open-hands/.env`

## Common Operations

### Deployment via Portainer
- Each directory represents a Portainer stack
- Copy compose.yaml content into Portainer stack configuration
- Ensure `stack.env` exists at repository root with proper values
- Services typically use `restart: always` or `restart: unless-stopped`

### Volume Management
- Most services use bind mounts to local directories (e.g., `./volumes/`, `./data/`)
- Some use named Docker volumes (e.g., `open-webui` volume)
- Persistent data stored locally for easy backup/management

### Port Mappings
- Services expose various ports (8080, 3000, 51820/udp, etc.)
- Check individual compose files for specific port assignments
- Some services use privileged mode or special capabilities (NET_ADMIN, SYS_MODULE)

## Development Notes

- Target platform: Raspberry Pi (ARM architecture)
- Many images use ARM-specific variants (`rpi-latest`, `unbound-rpi`)
- Services configured for Asian timezone (`Asia/Tokyo`)
- Japanese language support where applicable (`LANG=ja`)