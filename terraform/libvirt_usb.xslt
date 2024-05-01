<?xml version="1.0" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output omit-xml-declaration="yes" indent="yes"/>
  <xsl:template match="node()|@*">
     <xsl:copy>
       <xsl:apply-templates select="node()|@*"/>
     </xsl:copy>
  </xsl:template>

  <xsl:template match="/domain/devices">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
      
       <hostdev mode='subsystem' type='usb' managed='yes'>
      <source>
        <vendor id='0x0b95'/>
        <product id='0x7720'/>
      </source>
      <address type='usb' bus='0' port='1'/>
    </hostdev>
        
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
