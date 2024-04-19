<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:t="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="t" version="2.0">
<xsl:import href="../../epidocLib/resources/xsl/epidoc-stylesheets/start-edition.xsl"/>

<xsl:template match="t:w[@exist:matches]">
  <mark>
            <xsl:copy-of select="."/>
        </mark>
</xsl:template>
<xsl:template match="*[local-name() = 'match']">
    <mark>
            <xsl:copy-of select="./node()"/>
        </mark>
    <!-- <xsl:choose>
        <xsl:when test="./ancestor::t:expan">
            <mark>
                <xsl:copy-of>
                    <xsl:copy-of select="./ancestor::t:expan"/>
                    <xsl:apply-templates select="@*|node()"/>
            </xsl:copy-of>

            </mark>
        </xsl:when>
        <xsl:otherwise>
            <mark><xsl:copy-of select="./node()"/></mark>
        </xsl:otherwise>
    </xsl:choose> -->
 
</xsl:template>    
<xsl:template match="/">
  <xsl:apply-imports/>
    
</xsl:template>
</xsl:stylesheet>