<#-- 用于引入 前端 框架 easyui -->
<#-- 使用 <#include "common/top.ftl"> 引入 -->
<#assign base = request.contextPath />
<#assign easyui_version = "1.6.11" />

<#-- default 主题;默认图标 -->
<link rel="stylesheet" type="text/css" href="${base}/plugins/jquery-easyui/${easyui_version}/themes/default/easyui.css" />
<link rel="stylesheet" type="text/css" href="${base}/plugins/jquery-easyui/${easyui_version}/themes/icon.css" />
<#--自定义样式-->
<link rel="stylesheet" type="text/css" href="${base}/css/customCss2.0.css"/>

<#--  jquery 使用 easyui 自带的依赖版本;主依赖;中文支持（日期控件，校验规则······） -->
<script src="${base}/plugins/jquery-easyui/${easyui_version}/jquery.min.js"></script>
<script src="${base}/plugins/jquery-easyui/${easyui_version}/jquery.easyui.min.js"></script>
<#--<script src="${base}/plugins/jquery-easyui/${easyui_version}/datagrid-detailview.js"></script>-->
<script src="${base}/plugins/jquery-easyui/${easyui_version}/locale/easyui-lang-zh_CN.js"></script>
