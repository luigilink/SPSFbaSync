# SPSFbaSync

![Latest release date](https://img.shields.io/github/release-date/luigilink/SPSFbaSync.svg?style=flat)
![Total downloads](https://img.shields.io/github/downloads/luigilink/SPSFbaSync/total.svg?style=flat)  
![Issues opened](https://img.shields.io/github/issues/luigilink/SPSFbaSync.svg?style=flat)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)

## Description

SPSFbaSync is a PowerShell script to synchronize user information (email, display name, etc.)
from a SQL Membership Provider (Forms Based Authentication) database to the SharePoint User
Profile Service, and optionally to the User Information List.

Since SharePoint 2016 introduced **Active Directory Import**, FBA users no longer get their
email and other properties synced automatically. SPSFbaSync bridges that gap by pulling data
from your ASP.NET Membership database and pushing it into SharePoint. It also manages its own
Windows scheduled task so the sync can run unattended.

[Download the latest release here!](https://github.com/luigilink/SPSFbaSync/releases/latest)

## Requirements

- PowerShell 5.1 or later
- Administrative privileges on the SharePoint Server
- A SharePoint farm with a User Profile Service Application configured
- Access to the SQL Membership Provider (FBA) database

See the [Getting Started](https://github.com/luigilink/SPSFbaSync/wiki/Getting-Started) wiki page for details.

## Documentation

For usage, configuration, and getting-started information, visit the
[SPSFbaSync Wiki](https://github.com/luigilink/SPSFbaSync/wiki):

- [Getting Started](https://github.com/luigilink/SPSFbaSync/wiki/Getting-Started)
- [Configuration](https://github.com/luigilink/SPSFbaSync/wiki/Configuration)
- [Usage](https://github.com/luigilink/SPSFbaSync/wiki/Usage)
- [Release Process](https://github.com/luigilink/SPSFbaSync/wiki/Release-Process)

## Changelog

A full list of changes in each version can be found in the [change log](CHANGELOG.md).
