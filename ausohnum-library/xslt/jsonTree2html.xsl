<xsl:stylesheet xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:json="http://www.json.org" version="2.0">
    <!--    Attribute removed:xpath-default-namespace="http://www.tei-c.org/ns/1.0" -->
    <xsl:output method="html" omit-xml-declaration="yes" indent="yes"/>
    <xsl:param name="topConceptUri"/>
    <xsl:param name="xmlElement"/>
    <xsl:param name="dataType"/>
    <xsl:param name="index"/>
    <xsl:param name="pos"/>
    <xsl:param name="activateFollowing"/>
    <xsl:template name="children">
        <xsl:variable name="value">
            <xsl:if test="$dataType = 'uri'">
                <xsl:value-of select="./uri/text()"/>
            </xsl:if>
            <xsl:if test="$dataType = ''">
                <xsl:value-of select="./uri/text()"/>
            </xsl:if>
            <xsl:if test="$dataType = 'xml-value'">
                <xsl:value-of select="./xmlValue/text()"/>
            </xsl:if>
            <xsl:if test="$dataType = 'xml'">
                <xsl:value-of select="./xmlValue/text()"/>
            </xsl:if>
        </xsl:variable>
        <xsl:if test="./[@json:array] = 'true'">
            <li class="dropdown-submenu">
                <xsl:element name="a">
                    <xsl:attribute name="tabindex">-1</xsl:attribute>
                    <xsl:attribute name="menu">#<xsl:value-of select="$xmlElement"/>_<xsl:value-of select="$index"/>_<xsl:value-of select="$pos"/>
                    </xsl:attribute>
                    <xsl:attribute name="value">
                        <xsl:value-of select="$value"/>
                    </xsl:attribute>
                    <xsl:value-of select="./title/text()"/>
                </xsl:element>
              
                <ul class="dropdown-menu skosThesauDropDown" id="itemList-1">
                    <xsl:for-each select="./children">
                        <xsl:call-template name="children"/>
                    </xsl:for-each>
                </ul>
            </li>
            
        </xsl:if>
        <xsl:if test="./[@json:array] = 'false'">
            
            <li>
                <xsl:element name="a">
                    <xsl:attribute name="menu">#<xsl:value-of select="$xmlElement"/>_<xsl:value-of select="$index"/>_<xsl:value-of select="$pos"/>
                    </xsl:attribute>
                    <xsl:attribute name="value">
                        <xsl:value-of select="$value"/>
                    </xsl:attribute>
                    <xsl:value-of select="./title/text()"/>
                </xsl:element>
                
            </li>
            
        </xsl:if>
    </xsl:template>
    
    
    <xsl:template match="node() | @*">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="node() | @*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/children">
        <div class="dropdown">
            <xsl:element name="button">
                <xsl:attribute name="id">
                    <xsl:value-of select="$xmlElement"/>_<xsl:value-of select="$index"/>_<xsl:value-of select="$pos"/>
                </xsl:attribute>
                <xsl:attribute name="class">btn btn-xs btn-default dropdown-toggle elementWithValue<xsl:if test="number($pos) &gt; 1"> hidden</xsl:if>
                </xsl:attribute>
                <xsl:attribute name="type">button</xsl:attribute>
                <xsl:attribute name="name">
                    <xsl:value-of select="$xmlElement"/>
                </xsl:attribute>
                <xsl:attribute name="value"/>
                <xsl:attribute name="data-toggle">dropdown</xsl:attribute>
                <xsl:attribute name="activateFollowing">
                    <xsl:if test="$activateFollowing !=''">
                        <xsl:value-of select="$xmlElement"/>_<xsl:value-of select="$index"/>_<xsl:value-of select="number($activateFollowing)"/>
                    </xsl:if>
                </xsl:attribute>
                
                <em>Select an item</em>
                <span class="caret"/>
            </xsl:element>
            <!-- CP skosThesauDropDown-2-->
            <ul class="dropdown-menu skosThesauDropDown" id="itemList2">
                <xsl:for-each select="./children">
                    <xsl:call-template name="children"/>
                </xsl:for-each>
            </ul>
        </div>
        
    </xsl:template>
</xsl:stylesheet>