<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:pleiades="https://pleiades.stoa.org/peoples/vocab#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:cito="http://purl.org/spar/cito/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:lawd="http://lawd.info/ontology/" xmlns:dct="http://purl.org/dc/terms/" xmlns:skosThesau="https://ausohnum.huma-num.fr/skosThesau/" xmlns:apc="http://patrimonium.huma-num.fr/onto#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:fmpro="http://www.filemaker.com/fmpdsoresult" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ausohnum="http://ausonius.huma-num.fr/onto" xmlns:spatial="http://geovocab.org/spatial#" xmlns:prov="http://www.w3.org/TR/prov-o/#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:snap="http://onto.snapdrgn.net/snap#" xmlns:osgeo="http://data.ordnancesurvey.co.uk/ontology/geometry/" exclude-result-prefixes="fmpro xs" version="2.0">
    <xsl:output method="xml" omit-xml-declaration="yes" indent="yes"/>

    <xsl:template name="peopleRelation">
        <xsl:param name="projectName"/>
        <xsl:param name="relationUriBase"/>
        <xsl:variable name="relationId">
            <xsl:value-of select="concat('c', ./id[1] + 22148)"/>
        </xsl:variable>
        <xsl:variable name="relationUri">
            <xsl:value-of select="concat($relationUriBase, $relationId)"/>
        </xsl:variable>
        <xsl:element name="skos:Concept">
            <xsl:attribute name="xml:id">
                <xsl:value-of select="$relationId"/>
            </xsl:attribute>
            <xsl:attribute name="rdf:about">
                <xsl:value-of select="$relationUri"/>
            </xsl:attribute>
            <xsl:element name="skos:prefLabel">
                <xsl:attribute name="xml:lang">en</xsl:attribute>
                <xsl:value-of select="./relationLabelEn/text()"/>
            </xsl:element>
            <xsl:element name="skos:prefLabel">
                <xsl:attribute name="xml:lang">xml</xsl:attribute>
                <xsl:value-of select="./relationCode/text()"/>
            </xsl:element>
            <skos:broader rdf:resource="https://ausohnum.huma-num.fr/concept/c22148"/>
            <xsl:if test="./reverseDirection/text() !=''">
                <!--Test on "Contains"-->
                <xsl:for-each select="./reverseDirection">
                    <owl:reverseOf>
                        <xsl:attribute name="rdf:resource">
                            <xsl:value-of select="concat($relationUriBase, 'c', .+ 22148)"/>
                        </xsl:attribute>
                    </owl:reverseOf>
                </xsl:for-each>
            </xsl:if>
            <skos:inScheme rdf:resource="https://ausohnum.huma-num.fr/thesaurus/patrimonium/"/>
            <skosThesau:admin status="draft"/>
            <dct:creator rdf:resource="https://ausohnum.huma-num.fr/people/vrazanajao"> </dct:creator>
            <dct:created>
                <xsl:value-of select="current-dateTime()"/>
            </dct:created>
        </xsl:element>
    </xsl:template>


    <xsl:template match="/">
        <xsl:variable name="projectName">
            <xsl:value-of select="substring-before(FMPDSORESULT/DATABASE/text(), '.')"/>
        </xsl:variable>
        <xsl:variable name="relationUriBase">
            <xsl:text>https://ausohnum.huma-num.fr/concept/</xsl:text>
         </xsl:variable>
        <relations>
            <skos:Concept xml:id="c22148" rdf:about="https://ausohnum.huma-num.fr/concept/c22148">
                <skos:prefLabel xml:lang="en">People relationships</skos:prefLabel>
                <skos:broader rdf:resource="https://ausohnum.huma-num.fr/concept/c21849"/>
                <xsl:for-each select="FMPDSORESULT/ROW">
                    <skos:narrower>
                        <xsl:attribute name="rdf:resource">
                            <xsl:value-of select="concat($relationUriBase, 'c', ./id[1] + 22148)"/>
                        </xsl:attribute>
                    </skos:narrower>
                </xsl:for-each>
                <skos:inScheme rdf:resource="https://ausohnum.huma-num.fr/thesaurus/patrimonium/"/>
                <skosThesau:admin status="draft"/>
                <dct:creator rdf:resource="https://ausohnum.huma-num.fr/people/vrazanajao"/>
                <dct:created>
                    <xsl:value-of select="current-dateTime()"/>
                </dct:created>
            </skos:Concept>
            <xsl:for-each select="FMPDSORESULT/ROW">
                <xsl:call-template name="peopleRelation">
                    <xsl:with-param name="projectName" select="$projectName"/>
                    <xsl:with-param name="relationUriBase" select="$relationUriBase"/>
                </xsl:call-template>

            </xsl:for-each>
        </relations>
    </xsl:template>

</xsl:stylesheet>