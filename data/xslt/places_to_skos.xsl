<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs"
	xmlns:pleiades="https://pleiades.stoa.org/places/vocab#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#" 
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" 
	xmlns:dct="http://purl.org/dc/terms/" xmlns:skosThesau="http://ausonius.huma-num.fr/skosThesau/" 
	xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:map="http://www.w3c.rl.ac.uk/2003/11/21-skos-mapping#" 
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
	xmlns:time="http://www.w3.org/2006/time#" xmlns:dc="http://purl.org/dc/elements/1.1/"
	version="2.0">
	
	<xsl:template match="/">
		<!-- fundort_2022.xml fundorte modern -->
		<xsl:if test="//*:entry">
			<rdf:RDF>
				<xsl:for-each select="//*:entry">
					<pleiades:Place rdf:about="{concat('https://gams.uni-graz.at/o:fercan.places/', position())}">
						<skos:prefLabel xml:lang="en">
							<xsl:value-of select="*:fo"/>
						</skos:prefLabel>
						<skos:exactMatch rdf:resource="{*:pleiades}"/>
						<xsl:if test="*:desc">
							<skos:note>
								<xsl:value-of select="*:desc"/>
							</skos:note>
						</xsl:if>
					</pleiades:Place>
				</xsl:for-each>
				<!-- places.xml fundorte antik -->
				<xsl:if test="//*:place">
					<xsl:for-each select="//*:place">
						<pleiades:Place rdf:about="{concat('https://gams.uni-graz.at/o:fercan.places/', position() + 1000)}">
							<skos:prefLabel xml:lang="en">
								<xsl:value-of select="concat('Z ', *:name)"/>
							</skos:prefLabel>
							<skos:exactMatch rdf:resource="{*:id}"/>
						</pleiades:Place>
					</xsl:for-each>
				</xsl:if>
			</rdf:RDF>
		</xsl:if>
		
	</xsl:template>
	
	
</xsl:stylesheet>