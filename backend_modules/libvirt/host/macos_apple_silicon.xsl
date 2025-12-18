<?xml version="1.0" ?>
<xsl:stylesheet version="1.0" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:qemu="http://libvirt.org/schemas/domain/qemu/1.0">
  <xsl:output omit-xml-declaration="yes" indent="yes"/>

  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/domain/@type"><xsl:attribute name="type">hvf</xsl:attribute></xsl:template>
  <xsl:template match="/domain/os/type/@machine"><xsl:attribute name="machine">virt</xsl:attribute></xsl:template>

  <xsl:template match="/domain/devices/controller[@type='ide']"/>
  <xsl:template match="/domain/devices/disk">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="device">disk</xsl:attribute>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="/domain/devices/disk/target">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="bus">virtio</xsl:attribute>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/domain/devices/interface"/>

  <xsl:template match="/domain/features">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
      <gic version='3'/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/domain">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
      <qemu:commandline>
        <qemu:arg value='-netdev'/>
        <qemu:arg value='stream,id=net0,addr.type=unix,addr.path=/opt/homebrew/var/run/socket_vmnet'/>
        <qemu:arg value='-device'/>
        <qemu:arg value='virtio-net-pci,netdev=net0,addr=0x10,mac=52:54:00:12:34:56'/>
      </qemu:commandline>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
