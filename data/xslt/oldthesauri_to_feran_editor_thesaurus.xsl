<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:periodo="http://perio.do/#"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:dct="http://purl.org/dc/terms/"
	xmlns:skosThesau="https://ausohnum.huma-num.fr/skosThesau/"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:map="http://www.w3c.rl.ac.uk/2003/11/21-skos-mapping#"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:time="http://www.w3.org/2006/time#" xmlns:dc="http://purl.org/dc/elements/1.1/"
	exclude-result-prefixes="xs" version="2.0">
	
	
	
	<xsl:template match="/">
		
		
		
		<file>
			<thesauri>
				<!--This file is updated automatically when a change occurs in the project collection-->
				<last-update>2022-02-07T18:01:35.736+01:00</last-update>
				<generated-in>36.894 seconds</generated-in>
				<count/>
				<topConceptsUris>
					<topConceptUri status="draft">https://ausohnum.huma-num.fr/concept/c19930</topConceptUri>
					<topConceptUri status="published">https://ausohnum.huma-num.fr/concept/c66</topConceptUri>
					<topConceptUri status="draft">https://ausohnum.huma-num.fr/concept/c19298</topConceptUri>
					<topConceptUri status="draft">https://ausohnum.huma-num.fr/concept/c21849</topConceptUri>
					<topConceptUri status="published">https://ausohnum.huma-num.fr/concept/c39</topConceptUri>
					<topConceptUri status="draft">https://ausohnum.huma-num.fr/concept/c19422</topConceptUri>
					<topConceptUri status="draft">https://ausohnum.huma-num.fr/concept/c19290</topConceptUri>
					<topConceptUri status="published">https://ausohnum.huma-num.fr/concept/c6200</topConceptUri>
					<topConceptUri status="draft">https://ausohnum.huma-num.fr/concept/c19356</topConceptUri>
					<topConceptUri status="draft">https://ausohnum.huma-num.fr/concept/c19890</topConceptUri>
					<topConceptUri status="draft">https://ausohnum.huma-num.fr/concept/c19310</topConceptUri>
					<topConceptUri status="published">https://ausohnum.huma-num.fr/concept/c19933</topConceptUri>
					<topConceptUri status="published">https://ausohnum.huma-num.fr/concept/c25660</topConceptUri>
					<topConceptUri status="published">https://ausohnum.huma-num.fr/concept/c20583</topConceptUri>
					<topConceptUri status="published">https://ausohnum.huma-num.fr/concept/c25544</topConceptUri>
					<topConceptUri status="published">https://ausohnum.huma-num.fr/concept/c25328</topConceptUri>
					<topConceptUri status="published">https://ausohnum.huma-num.fr/concept/c25305</topConceptUri>
					<topConceptUri status="published">https://ausohnum.huma-num.fr/concept/c24686</topConceptUri>
					<topConceptUri status="published">https://ausohnum.huma-num.fr/concept/c24476</topConceptUri>
					<topConceptUri status="published">https://ausohnum.huma-num.fr/concept/c24110</topConceptUri>
					<topConceptUri status="published">https://ausohnum.huma-num.fr/concept/c23775</topConceptUri>
					<topConceptUri status="draft">https://ausohnum.huma-num.fr/concept/c26554</topConceptUri>
					<topConceptUri status="draft">https://ausohnum.huma-num.fr/concept/c26467</topConceptUri>
				</topConceptsUris>
				<user>vrazanajao</user>
				<thesaurus xml:lang="en">
					<children xmlns:json="http://www.json.org" json:array="true">
						<title>Thesaurus ausohnum</title>
						<id>c1</id>
						<key>c1</key>
						<isFolder>true</isFolder>
						<orderedCollection json:literal="true">true</orderedCollection>
						<lang>en</lang>
						<children json:array="true" status="published" type="collectionItem" groups="">
							<title>＜ EAGLE Vocabulary - Dating Criteria ＞</title>
							<id>c23775</id>
							<uri>https://ausohnum.huma-num.fr/concept/c23775</uri>
							<key>c23775</key>
							<xmlValue/>
							<lang>en</lang>
							<isFolder>true</isFolder>
							<xsl:for-each select="//skos:Concept">
								<xsl:sort select="skos:prefLabel"/>
								
								
								<xsl:variable name="ID" select="substring-after(@rdf:about, 'https://gams.uni-graz.at/o:fercan.arch#')"/>
								
								<children json:array="false" status="draft" type="collectionItem">
									<title><xsl:value-of select="normalize-space(skos:prefLabel)"/></title>
									<id><xsl:value-of select="$ID"/></id>
									<uri><xsl:value-of select="@rdf:about"/></uri>
									<key><xsl:value-of select="$ID"/></key>
									<xmlValue/>
									<lang>en</lang>
								</children>
							</xsl:for-each>
						</children>
					</children>
				</thesaurus>
			</thesauri>
		</file>
	</xsl:template>
	
	
</xsl:stylesheet>
