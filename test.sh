#!/bin/bash

$bash create-high-availability-vm-with-sets.sh J1.2103.E0-WCI1-TraHoangViet

$backendPool = New-AzLoadBalancerBackendAddressPoolConfig -Name "travietBackEndPool"

$Location = $(Get-AzureRmResourceGroup -ResourceGroupName J1.2103.E0-WCI1-TraHoangViet).Location

$publicIP = New-AzPublicIpAddress `
  -ResourceGroupName J1.2103.E0-WCI1-TraHoangViet `
  -Location $Location `
  -AllocationMethod "Static" `
  -Name "travietPublicIP"

$frontendIP = New-AzLoadBalancerFrontendIpConfig `
  -Name "travietFrontEnd" `
  -PublicIpAddress $publicIP

$backendPool = New-AzLoadBalancerBackendAddressPoolConfig -Name "travietBackEndPool"

$probe = New-AzLoadBalancerProbeConfig `
  -Name "travietHealthProbe" `
  -Protocol http `
  -Port 80 `
  -IntervalInSeconds 5 `
  -ProbeCount 2 `
  -RequestPath "/"


$lbrule = New-AzLoadBalancerRuleConfig `
  -Name "travietLoadBalancerRule" `
  -FrontendIpConfiguration $frontendIP `
  -BackendAddressPool $backendPool `
  -Protocol Tcp `
  -FrontendPort 80 `
  -BackendPort 80 `
  -Probe $probe

$lb = New-AzLoadBalancer `
  -ResourceGroupName J1.2103.E0-WCI1-TraHoangViet `
  -Name 'travietLoadBalancer' `
  -Location $Location `
  -FrontendIpConfiguration $frontendIP `
  -BackendAddressPool $backendPool `
  -Probe $probe `
  -LoadBalancingRule $lbrule

$nic1 = Get-AzNetworkInterface -ResourceGroupName J1.2103.E0-WCI1-TraHoangViet -Name "webNic1"
$nic2 = Get-AzNetworkInterface -ResourceGroupName J1.2103.E0-WCI1-TraHoangViet -Name "webNic2"

$nic1.IpConfigurations[0].LoadBalancerBackendAddressPools = $backendPool
$nic2.IpConfigurations[0].LoadBalancerBackendAddressPools = $backendPool

Set-AzNetworkInterface -NetworkInterface $nic1 -AsJob
Set-AzNetworkInterface -NetworkInterface $nic2 -AsJob

Write-Host http://$($(Get-AzPublicIPAddress `
  -ResourceGroupName J1.2103.E0-WCI1-TraHoangViet `
  -Name "travietPublicIP").IpAddress)

echo '---------------------------------------------------'
echo '             Setup Script Completed'
echo '---------------------------------------------------'
