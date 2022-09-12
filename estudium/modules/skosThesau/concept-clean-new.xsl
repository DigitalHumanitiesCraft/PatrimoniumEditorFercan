<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:periodo="http://perio.do/#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:saxon="http://saxon.sf.net/" xmlns:sql="java:/net.sf.saxon.sql.SQLElementFactory" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:skosThesau="https://ausohnum.huma-num.fr/skosThesau/" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:json="http://www.json.org" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:time="http://www.w3.org/2006/time#" xmlns:dc="http://purl.org/dc/elements/1.1/" exclude-result-prefixes="xs dc skos skosThesau tei xhtml time dcterms rdf periodo" version="2.0" extension-element-prefixes="saxon sql skos">
    <xsl:param name="lang"/>
    <xsl:param name="newId"/>
    <xsl:param name="baseURI"/>
    <xsl:strip-space elements="*"/>
    <xsl:output omit-xml-declaration="yes" indent="yes"/>
    <xsl:template match="skos:Concept">
        <xsl:if test="./@nodeLabel = 'nodeLabel'">
            <xsl:element name="skos:Collection">
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="$newId"/>
                </xsl:attribute>
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select="$baseURI"/>
                    <xsl:text>/</xsl:text>
                    <xsl:value-of select="$newId"/>
                </xsl:attribute>
                <xsl:apply-templates select="@* | node()"/>
            </xsl:element>
        </xsl:if>
        <xsl:if test="./@nodeLabel = ''">
            <xsl:element name="skos:Concept">
                <xsl:attribute name="xml:id">
                    <xsl:value-of select="$newId"/>
                </xsl:attribute>
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select="$baseURI"/>
                    <xsl:value-of select="$newId"/>
                </xsl:attribute>
                <xsl:copy-of select="@* except (@nodeLabel)"/>
                <xsl:apply-templates select="@* | node()"/>
                <!--                <xsl:copy-of select="./node()" copy-namespaces="no"/>-->
            </xsl:element>
        </xsl:if>
    </xsl:template>
    <!--    <xsl:template match="skos:prefLabel[not(normalize-space() = '')]"/>-->
    <xsl:template match="skos:prefLabel | skos:altLabel | dc:title | skos:scopeNote">
        <xsl:if test="normalize-space(string(.)) != ''">
            <xsl:copy copy-namespaces="no">
                <xsl:apply-templates select="node() | @*"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
    <xsl:template match="@nodeLabel"/>
    <xsl:template match="node() | @*">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="*[not(@* | * | comment() | processing-instruction()) and normalize-space() = '']"/>

    <!-- Removes all nodes with any empty attribute -->
    <xsl:template match="*[@rdf:resource = '']"/>
</xsl:stylesheet>