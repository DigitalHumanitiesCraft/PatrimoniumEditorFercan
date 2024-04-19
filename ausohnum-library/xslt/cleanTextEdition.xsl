<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" version="2.0">
    <xsl:output method="text" omit-xml-declaration="yes" indent="yes"/>
    <xsl:preserve-space elements=""/>
    <xsl:template match="node() | @*">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="*" priority="-0.4">
        <xsl:element name="{local-name()}">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>  
    <xsl:template match="text()[normalize-space() = '']"/>
    <xsl:template match="*[not(@* | * | comment() | processing-instruction()) and normalize-space() = '']"/>

    <!-- Removes all nodes with any empty attribute -->

</xsl:stylesheet>