<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="#all"
	version="2.0">
	
	<!-- --> 
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	<!--  target="#MAJ.1 #MIN.1" -->
	<xsl:template match="*:TEI/*:text/*:body/*:linkGrp/*:link">
		<xsl:variable name="id" select="normalize-space(@target)"/>
		<link target="{concat('#MAJ.', $id, ' #MIN.', $id)}">
			<xsl:apply-templates/>
		</link>
	</xsl:template>

	<!-- fix @xml:id in bibliography; adding "LIT." -->
	<xsl:template match="*:TEI/*:text/*:body/*:div[@type='bibliography'][@subtype='editions']/*:listBibl/*:bibl">
		<bibl xml:id="{concat('LIT.', @xml:id)}">
			<xsl:apply-templates/>
		</bibl>
	</xsl:template>
	
	<xsl:template match="*:TEI/*:text/*:body/*:div[@xml:id='majuscule']/*:ab[not(*:orig)]">
		<xsl:copy>
			<orig>
				<xsl:apply-templates/>
			</orig>
		</xsl:copy>
	</xsl:template>
	
	<!-- lb xml:id MIN. -->
	<xsl:template match="*:TEI/*:text/*:body/*:div[@xml:id='minuscule']/*:ab/*:lb">
		<lb n="{@n}" xml:id="{concat('MIN.', @n)}"/>
	</xsl:template>
	
	<!-- lb xml:id MAJ. -->
	<xsl:template match="*:TEI/*:text/*:body/*:div[@xml:id='majuscule']/*:ab/*:lb">
		<lb n="{@n}" xml:id="{concat('MAJ.', @n)}"/>
	</xsl:template>
	
	<xsl:template match="*:i"/>
	
	<!-- add <ref type="context" target="context:fercan.arch.fragment">Fragment</ref> -->
	<xsl:template match="/*:TEI/*:teiHeader/*:fileDesc/*:sourceDesc/*:msDesc/*:physDesc/*:decoDesc/*:decoNote/*:term">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<ref type="context" target="{concat( 'context:fercan.arch.', translate(lower-case(normalize-space(text())), ' ', '') )}">
				<xsl:apply-templates/>	
			</ref>
		</xsl:copy>
	</xsl:template>
	
	<!-- adding context in @target to ref; <ref ana="https://gams.uni-graz.at/o:fercan.arch#C.120210" target="context:fercan.material.kalkstein" type="context">Kalkstein</ref> -->
	<xsl:template match="/*:TEI/*:teiHeader/*:fileDesc/*:sourceDesc/*:msDesc/*:physDesc/*:objectDesc/*:supportDesc/*:support/*:material/*:ref">
		<ref ana="{@ana}" target="{concat('context:fercan.material.', translate(lower-case(normalize-space(text())), ' ', '') )}">
			<xsl:apply-templates/>
		</ref>
	</xsl:template>
	
	<!-- skip all Editors's comments in back/note -->
	<xsl:template match="*:back"/>
	
	<!-- remove if empty -->
	<xsl:template match="@notBefore"/>
	<xsl:template match="@notAfter"/>
	
	<!-- fix <p> in <p> -->
	<xsl:template match="*:p/*:p"><xsl:apply-templates/></xsl:template>
	
	<!-- remove all comments -->
	<xsl:template match="comment()"/>
	
	<!-- replace <br/>  -->
	<xsl:template match="*:br">
		<lb/>
	</xsl:template>
	
	<!-- add <p> because of textarea generated <br> from editor; fix on webpage?  -->
	<xsl:template match="/*:TEI/*:teiHeader/*:fileDesc/*:sourceDesc/*:msDesc/*:history/*:provenance">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:choose>
				<xsl:when test="*:p">
					<xsl:apply-templates/>
				</xsl:when>
				<xsl:otherwise>
					<p>
						<xsl:apply-templates/>
					</p>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>
	
	<!-- skip nasty attributes from schema -->
	<xsl:template match="@instant"/>
	<xsl:template match="@default"/>
	<xsl:template match="@full"/>
	<xsl:template match="@status"/>
	<xsl:template match="@part"/>
	<xsl:template match="@anchored"/>
	<xsl:template match="@sample"/>
	
</xsl:stylesheet>