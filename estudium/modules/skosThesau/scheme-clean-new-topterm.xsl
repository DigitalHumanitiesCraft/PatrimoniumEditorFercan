<xsl:stylesheet xmlns:bf="http://betterform.sourceforge.net/xforms" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:xf="http://www.w3.org/2002/xforms" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dct="http://purl.org/dc/terms/" xmlns:skosThesau="https://ausohnum.huma-num.fr/skosThesau/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:map="http://www.w3c.rl.ac.uk/2003/11/21-skos-mapping#" xmlns:dc="http://purl.org/dc/elements/1.1/" exclude-result-prefixes="dc skosThesau rdfs dct map rdf skos bf xf" version="2.0">
    <xsl:output omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="schemeShortName"/>
    <xsl:template match="skos:Concept | skos:Collection">
        <xsl:if test="normalize-space(string(.)) != ''">
            <xsl:copy copy-namespaces="no">
                <xsl:apply-templates select="node() | @*"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
    <xsl:template match="skos:prefLabel | skos:altLabel | dc:title | skos:scopeNote">
        <xsl:if test="normalize-space(string(.)) != ''">
            <xsl:copy copy-namespaces="no">
                <xsl:apply-templates select="node() | @*"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>
    <xsl:template match="skos:inScheme">
        <xsl:copy>
            <xsl:attribute name="rdf:resource">
                <xsl:value-of select="./@rdf:resource"/>
                <xsl:value-of select="$schemeShortName"/>
                <xsl:text>/</xsl:text>
            </xsl:attribute>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="node() | @*">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="*[not(@* | * | comment() | processing-instruction()) and normalize-space() = '']"/>
    <!-- Removes all nodes with any empty attribute -->
    <xsl:template match="*[@rdf:resource = '']"/>
</xsl:stylesheet>