<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:t="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="t" version="2.0">
    <xsl:import href="../../epidocLib/resources/xsl/epidoc-stylesheets/start-edition.xsl"/>
    
    <!-- <xsl:variable name="skeywordUri" select="$keywordUri"></xsl:variable>  -->
    
    <xsl:param name="keywordUri"/>
    <xsl:template match="t:rs">
        <xsl:variable name="ref" select="./@ref"/>
        <xsl:choose>
            <xsl:when test="contains($keywordUri, $ref)">
                <xsl:call-template name="mark">
                </xsl:call-template>
            </xsl:when>
            
            <xsl:when test="./@type='person'">
                <xsl:element name="span">
                    <xsl:attribute name="class">person teiPreviewperson persName</xsl:attribute>
                    <xsl:element name="a">
                        <xsl:attribute name="title">Open the person's record in a new window (<xsl:copy-of select="./@ref"/>)</xsl:attribute>
                        <xsl:attribute name="href">
                            <xsl:copy-of select="./@key"/>
                        </xsl:attribute>
                        <xsl:attribute name="target">_about</xsl:attribute>
                        <xsl:element name="span">
                            <xsl:attribute name="class">teiPreviewIconperson</xsl:attribute>
                            <xsl:text>👤</xsl:text>
                        </xsl:element>
                    </xsl:element>
                    <xsl:copy>
                        <xsl:apply-templates/>
                    </xsl:copy>
                    
                </xsl:element>
            </xsl:when>
            
            
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="t:placeName">
        <xsl:element name="span">
            <xsl:attribute name="class">place teiPreviewplace placeName</xsl:attribute>
            <xsl:element name="a">
                <xsl:attribute name="title">Open this place in a new window (<xsl:copy-of select="./@ref"/>)</xsl:attribute>
                <xsl:attribute name="href">
                    <xsl:copy-of select="./@key"/>
                </xsl:attribute>
                <xsl:attribute name="target">_about</xsl:attribute>
                <xsl:element name="span">
                    <xsl:attribute name="class">teiPreviewIconplace</xsl:attribute>
                    <xsl:text>⌘</xsl:text>
                </xsl:element>
            </xsl:element>
            <xsl:copy>
                <xsl:apply-templates/>
            </xsl:copy>
            
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="mark">
        <xsl:element name="mark">
            <xsl:attribute name="class">keywordMatch</xsl:attribute>
            <xsl:attribute name="title">Concept "<xsl:copy-of select="./@key"/>" [<xsl:copy-of select="./@ref"/>]</xsl:attribute>
            <xsl:copy-of select="./node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="t:head"/>
    <xsl:template match="t:g">
        <xsl:choose>
        <xsl:when test="./text != ''">
                <xsl:value-of select="."/>
            </xsl:when>
        <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
    </xsl:choose>
    </xsl:template>
    <xsl:template match="/">
        <xsl:apply-imports/>
        
    </xsl:template>
    <!-- <xsl:include href="epidoc-stylesheets/start-txt.xsl"/>   -->
</xsl:stylesheet>