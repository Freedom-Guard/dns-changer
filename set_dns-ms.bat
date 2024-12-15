@echo off
setlocal enabledelayedexpansion

:: Check if both primary and secondary DNS are provided
if "%~2"=="" (
    echo Usage: set_dns.bat <primary_dns_ipv4> <secondary_dns_ipv4>
    echo Example: set_dns.bat 8.8.8.8 8.8.4.4
    echo Use "clear" as both arguments to reset DNS to DHCP for all interfaces
    exit /b 1
)

:: Get the provided DNS addresses
set PRIMARY_DNS=%~1
set SECONDARY_DNS=%~2

:: Get the list of all network interfaces
for /f "skip=3 tokens=2 delims=:" %%I in ('netsh interface show interface') do (
    set InterfaceName=%%I
    set InterfaceName=!InterfaceName:~1!
    
    :: Reset DNS to DHCP if both arguments are "clear"
    if /i "%PRIMARY_DNS%"=="clear" if /i "%SECONDARY_DNS%"=="clear" (
        echo Resetting DNS settings for !InterfaceName! to DHCP...
        netsh interface ipv4 set dnsservers name="!InterfaceName!" source=dhcp
    ) else (
        :: Set the primary DNS server
        echo Setting primary DNS for !InterfaceName! to %PRIMARY_DNS%...
        netsh interface ipv4 set dnsservers name="!InterfaceName!" source=static addr=%PRIMARY_DNS% register=primary

        :: Set the secondary DNS server
        echo Setting secondary DNS for !InterfaceName! to %SECONDARY_DNS%...
        netsh interface ipv4 add dnsservers name="!InterfaceName!" addr=%SECONDARY_DNS% index=2
    )
)

:: Notify user of completion
echo All operations completed successfully.
pause
