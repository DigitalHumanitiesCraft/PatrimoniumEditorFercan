<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!--    Attribute removed:xpath-default-namespace="http://www.tei-c.org/ns/1.0" -->
    
    
    <xsl:output method="xml" omit-xml-declaration="yes" indent="yes"/>
    
    <xsl:preserve-space elements=""/>
    <!--<xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>-->
    <!--    <xsl:template match="*" priority="-0.4">
        <xsl:element name="{local-name()}">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>-->
    <xsl:template match="div[@type = 'textpart']/ab">
        <xsl:copy copy-namespaces="no">
            <xsl:value-of select="replace(., '&lt;', 'dd')"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="/*[local-name()='data']">
        <xsl:element name="data" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="@*, node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="node() | @*">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    <!--
    <xsl:template match="text()[normalize-space() = '']"/>
    <xsl:template match="*[not(@* | * | comment() | processing-instruction()) and normalize-space() = '']"/>
    -->
    <!-- Removes all nodes with any empty attribute -->

</xsl:stylesheet>