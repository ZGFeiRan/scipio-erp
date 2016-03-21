<#--
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing,
software distributed under the License is distributed on an
"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
KIND, either express or implied.  See the License for the
specific language governing permissions and limitations
under the License.
-->
<#-- variable setup and worker calls -->
<#macro categoryList productCategoryId level isMultiLevel path count class="" previousCategoryId="">
    <#-- Cato: sometimes this happens for reasons I'm not sure... just prevent it here -->
    <#if previousCategoryId == productCategoryId>
      <#local previousCategoryId = "">
    </#if>
    <#assign productCategory = delegator.findOne("ProductCategory", {"productCategoryId" : productCategoryId}, true)/>
    <#assign contentCategoryName = Static["org.ofbiz.product.category.CategoryContentWrapper"].getProductCategoryContentAsText(productCategory, "CATEGORY_NAME", locale, dispatcher, "html")!>
    <#assign contentCategoryDesc = Static["org.ofbiz.product.category.CategoryContentWrapper"].getProductCategoryContentAsText(productCategory, "DESCRIPTION", locale, dispatcher, "html")!>    
    <#assign active = false>
    <#if (curCategoryId?has_content && curCategoryId == productCategoryId) || urlContainsPathPart(StringUtil.wrapString(currentCategoryPath!""), productCategoryId)>
      <#assign active = true>
    </#if>
    <#assign categoryUrl><@ofbizCatalogUrl currentCategoryId=productCategoryId previousCategoryId=previousCategoryId/></#assign>
    <#assign linkText><#if contentCategoryName?has_content>${contentCategoryName}<#else>${contentCategoryDesc!""}</#if> <#if (count?number > 0)>(${count})</#if></#assign>
    <#local class = addClassArg(class, "menu-${level}")>
    <@menuitem type="link" href=categoryUrl text=linkText class=class active=active>
      <#if isMultiLevel>
        <#if currentCategoryPath.contains("/"+productCategoryId)>
            <#assign nextLevel=level+1/>
            <#if catList.get("menu-"+nextLevel)?has_content>
                <#assign nextList = catList.get("menu-"+nextLevel) />
                <@iterateList currentList=nextList currentLevel=nextLevel isMultiLevel=true previousCategoryId=productCategoryId/>
            </#if>
        </#if>
      </#if>
    </@menuitem>        
</#macro>

<#macro iterateList currentList currentLevel isMultiLevel previousCategoryId="">
        <#-- Cato: NOTE: this will automatically figure out it's a nested menu and it will inherit the type of the parent -->
        <@menu id="menu-${currentLevel!0}">
          <#list currentList as item>
            <#if item.catId?has_content>
              <@categoryList productCategoryId=item.catId level=currentLevel!0 isMultiLevel=isMultiLevel path=item.path!"" count=item.count previousCategoryId=previousCategoryId/>
            </#if>
          </#list>
        </@menu>
</#macro>

<#if catList?has_content || topLevelList?has_content>
    <@menu id="menu-0" type="sidebar">
        <#if catList?has_content && catList.get("menu-0")?has_content><#-- CATO: Display each categoryItem -->
          <!-- current categories -->
          <@categoryList productCategoryId=topCategoryId level=0 isMultiLevel=false path="" count=0 class=styles.menu_sidebar_itemdashboard!/>
          <#list catList.get("menu-0") as item>
            <#if item.catId?has_content>
              <#-- Cato: FIXME?: sanity check - each item should have as parent the top category - currently this is not always true -->
              <#if Static["org.ofbiz.product.category.CategoryWorker"].isCategoryChildOf(delegator, dispatcher, topCategoryId, item.catId)>
                <@categoryList productCategoryId=item.catId level=0 isMultiLevel=true path=item.path!"" count=item.count previousCategoryId=topCategoryId!""/>
              <#else>
                <#assign dummy = Static["org.ofbiz.base.util.Debug"].logWarning("Cato: WARN: Side deep category " + item.catId + " not child of top category " + (topCategoryId!"") + "; discarding", "sidedeepcategoryftl")>
              </#if>
            </#if>
          </#list>
        <#elseif topLevelList?has_content><#-- Cato: Fallback for empty categories / catalogs -->
          <!-- top categories -->
          <#list topLevelList as productCategoryId>
            <#if productCategoryId?has_content>
              <@categoryList productCategoryId=productCategoryId level=0 isMultiLevel=false path="" count=0 previousCategoryId=topCategoryId!""/>
            </#if>
          </#list>
        </#if>
    </@menu>
</#if>

