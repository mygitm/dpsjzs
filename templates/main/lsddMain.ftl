<!DOCTYPE html>
<html lang="zh-cn" xmlns="http://www.w3.org/1999/html" xmlns="http://www.w3.org/1999/html">
<head>
    <title>${city_name!}卫生信息实时管理系统</title>
    <#include "../common/top.ftl">
    <script language="javascript" type="text/javascript" src="${base}/plugins/echarts/echarts.js"></script>
    <script language="javascript" type="text/javascript" src="${base}/plugins/js/echarts-wordcloud.js"></script>
    <script language="javascript" type="text/javascript" src="${base}/plugins/js/china.js"></script>
    <script language="javascript" type="text/javascript" src="${base}/js/lsddMain.js"></script>
    <script src="${base}/plugins/bootstrap3/js/bootstrap.min.js"></script>
    <script language="javascript" type="text/javascript"
            src="${base}/plugins/gridview/jquery.hyjk.paginate.ui.js"></script>
    <script language="javascript" type="text/javascript" src="${base}/plugins/gridview/showTips.js"></script>
    <link rel="stylesheet" type="text/css" href="${base}/css/lsddMain.css"/>
    <link rel="stylesheet" type="text/css" href="${base}/plugins/gridview/css/gridview.css"/>
    <link rel="stylesheet" type="text/css" href="${base}/plugins/gridview/css/loaders.css"/>

    <link rel="stylesheet" type="text/css" href="${base}/plugins/gridview/css/bootstrap.min.css"/>
    <script language="JavaScript" type="text/javascript">
        var qxMZ, xzMZ, jgMZ, startDataMZ, endDataMZ;
        var qxZY, xzZY, jgZY, startDataZY, endDataZY;
        var shantouDate, text, clear, selectedOrgid, diseaseNephogramsClear;
        var setTitleDate = new Object;
        var cityMap;
        var lsddChart;
        $(document).ready(function () {
            $(".container-fluid").width(window.screen.width - 50);
            lsddChart = new lsddCharts();
            $('#shantou_tables').tabs({
                border: false,
                onSelect: function (title, index) {
                    searchMZorZYservice(index, selectedOrgid);
                }
            });
            lsddChart.ajaxCharts('lsddCharts/queryTodayMzOrZyMoney?lsddId=${map_lsdd_id!}&grade=${grade!}', function (result) {
                createShanTouTableDate($("#shantouylmz_table tbody"), result);
            });
            lsddChart.ajaxCharts('lsddCharts/queryUnitnameMap?lsddId=${map_lsdd_id!}', function (result) {
                var object = new Object();
                if (3 ==${grade!}) {
                    lsddChart.units.push({unitId: '${map_lsdd_id!}', unitName: '${city_name!}'});
                } else {
                    lsddChart.units.push({unitId: "all", unitName: "全部"});
                }
                $.each(result, function (key, value) {
                    lsddChart.mapCityDate.push({
                        name: converDataString(value.UNITNAME),
                        value: converDataString(value.MAPVALUE),
                        selected: eval(value.UNITSELECTD)
                    });
                    object[value.UNITID] = value.UNITNAME;
                    lsddChart.units.push({"unitId": value.UNITID, "unitName": value.UNITNAME});
                });
                lsddChart.geoCoordCity = object;
            });
            lsddChart.ajaxCharts('lsddCharts/queryLongitudeLatitude?lsddId=${map_lsdd_id!}&grade=${grade!}', function (result) {
                var obj = new Object;
                $.each(result, function (key, value) {
                    obj[value.UNITID] = eval(value.LATITUDE_VALUE);
                })
                lsddChart.geoCoordMap = obj;
            });
            cityMap = echarts.init(document.getElementById('cityMap'));
            setInterval(intervalCharts, 6000);
            diseaseNephogramsClear = setInterval(intervalNephograms, 10000);
            text = $(".table_two tbody:first");
            text.hover(function () {
                clearInterval(clear);
            }, function () {
                clearInterval(clear);
                clear = setInterval(gongdongTable, 2000);
            }).trigger("mouseleave");
            $('.table_two tbody tr').hover(function () {
                        $(this).siblings().css({"background": "", "color": ""});
                        $(this).css({"background": "rgba(11,98,195,0.6)", "color": "#FFFFFF"});
                        var selectMap = convertData($(this).children('td:eq(1)').text());
                        setTitleDate.orgid = $(this).children('td:eq(0)').text();
                        setTitleDate.orgname = $(this).children('td:eq(2)').text();
                        setMap(selectMap);
                    },
                    function () {
                        $(this).siblings().css({"background": "", "color": ""});
                        $(this).css({"background": "rgba(11,98,195,0.6)", "color": "#FFFFFF"});
                    });
            $('.table_two tbody tr').dblclick(function () {
                selectedOrgid = setTitleDate.orgid;
                var index = $('#shantou_tables').tabs('getTabIndex', $('#shantou_tables').tabs('getSelected'));
                $("#shantou_window").window('open').window("setTitle", setTitleDate.orgname);
                searchMZorZYservice(index, selectedOrgid);
            });
            $('#TextStartTime').datetimebox({
                showSeconds: false,
                onSelect: function (date) {
                    var y = date.getFullYear();
                    var m = date.getMonth() + 1;
                    var d = date.getDate();
                    var time = $('#TextStartTime').datetimebox('spinner').spinner('getValue');
                    var dateTime = y + "-" + (m < 10 ? ("0" + m) : m) + "-" + (d < 10 ? ("0" + d) : d) + ' ' + time;
                    $('#TextStartTime').datetimebox('setText', dateTime);
                    $('#TextStartTime').datetimebox('hidePanel');
                }
            });
            intervalCharts();
            intervalNephograms();
            $.get('${base}/plugins/echarts/china-main-city/${map_file!}', function (_shantou) {
                shantouDate = _shantou;
                try {
                    if (3 ==${grade!}) {
                        var features = new Array();
                        $.each(shantouDate.features, function (key, value) {
                            if (typeof value != "undefined") {
                                if (value.properties.name == '${city_name!}') {
                                    features.push(shantouDate.features[key]);
                                }
                            }
                        });
                        shantouDate.features = features;
                        $('#qxCodeValueZY').combobox('disable');
                        $('#qxCodeValueMZ').combobox('disable');
                    }
                    echarts.registerMap('${map_city_name!}', shantouDate);
                    lsddChart.mapOption.layoutCenter = ['${map_layout_x!}', '${map_layout_y!}'];
                    lsddChart.mapOption.geo = {map: '${map_city_name!}', show: false};
                    lsddChart.mapOption.series[0].zoom =${map_size!};
                    lsddChart.mapOption.series[0].map = '${map_city_name!}';
                    lsddChart.mapOption.series[1].data = convertDataTow(lsddChart.getValues());
                    setMap("");
                } catch (e) {
                    console.log("地图数据加载错误" + e);

                }
            });
            mz_initUnitCombobox();
            zy_initUnitCombobox();
            $('#qxCodeValueMZ').combobox({valueField: 'unitId', textField: 'unitName', data: lsddChart.units});
            $('#qxCodeValueZY').combobox({valueField: 'unitId', textField: 'unitName', data: lsddChart.units});
            //格式化日期函数
            Date.prototype.Format = function (fmt) {
                var o = {
                    "M+": this.getMonth() + 1,
                    "d+": this.getDate(),
                    "h+": this.getHours(),
                    "m+": this.getMinutes(),
                    "s+": this.getSeconds(),
                    "q+": Math.floor((this.getMonth() + 3) / 3),
                    "S": this.getMilliseconds()
                };
                if (/(y+)/.test(fmt)) fmt = fmt.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
                for (var k in o)
                    if (new RegExp("(" + k + ")").test(fmt)) fmt = fmt.replace(RegExp.$1, (RegExp.$1.length == 1) ? (o[k]) : (("00" + o[k]).substr(("" + o[k]).length)));
                return fmt;
            }


        });

        function intervalCharts() {
            // lsddChart.showDiseaseNephograms(lsddChart.chartsInit(document.getElementById('qsdtjjbyt')));
            var initServiceMzBar = lsddChart.showServiceMzBar(lsddChart.chartsInit(document.getElementById('mzyw_total')), '${map_lsdd_id!}');
            if (!lsddChart.initServiceMzBarOnClick && typeof initServiceMzBar != "undefined") {
                lsddChart.initServiceMzBarOnClick = true;
                initServiceMzBar.on('click', function (params) {
                    if (3 ==${grade!}) {
                        $('#qxCodeValueMZ').combobox('select', '${map_lsdd_id!}');
                    } else {
                        $('#qxCodeValueMZ').combobox('select', 'all');
                    }
                    lsddChart.ajaxCharts('lsddCharts/queryOrgnameAndUnitName?unitId=${map_lsdd_id!}&grade=${grade!}', function (result) {
                        mz_setOrganizationAndUnit(result);
                    });
                    mzServiceDetail();
                    $("#shantouMZservice_window").window('open').window("setTitle", "门诊业务明细");
                });
            }
            var initServiceZyBar = lsddChart.showServiceZyBar(lsddChart.chartsInit(document.getElementById('zyyw_total')), '${map_lsdd_id!}');
            if (!lsddChart.initServiceZyBarOnClick && typeof initServiceZyBar != "undefined") {
                lsddChart.initServiceZyBarOnClick = true;
                initServiceZyBar.on('click', function (params) {

                    if (3 ==${grade!}) {
                        $('#qxCodeValueZY').combobox('select', '${map_lsdd_id!}');
                    } else {
                        $('#qxCodeValueZY').combobox('select', 'all');
                    }
                    lsddChart.ajaxCharts('lsddCharts/queryOrgnameAndUnitName?unitId=${map_lsdd_id!}&grade=${grade!}', function (result) {
                        zy_setOrganizationAndUnit(result);
                    });
                    zyServiceDetail();
                    $("#shantouZYservice_window").window('open').window("setTitle", "住院业务明细");
                });
            }
            lsddChart.showYljgsrBar(lsddChart.chartsInit(document.getElementById('qsdtjgsr')), '${map_lsdd_id!}');
            lsddChart.showJdqybar(lsddChart.chartsInit(document.getElementById('jdl_qyl')), '${map_lsdd_id!}');
            queryCityHospitalTotals();
            setZyMzMoneyNumber();
        }

        function intervalNephograms() {
            var diseaseNephograms = lsddChart.showDiseaseNephograms(lsddChart.chartsInit(document.getElementById('qsdtjjbyt')), '${map_lsdd_id!}', '${grade!}');
            if (!lsddChart.diseaseNephogramsOnmouse) {
                diseaseNephograms.on('mouseout', function () {
                    clearInterval(diseaseNephogramsClear);
                    diseaseNephogramsClear = setInterval(intervalNephograms, 10000);
                });
                diseaseNephograms.on('mouseover', function () {
                    clearInterval(diseaseNephogramsClear);
                });
                lsddChart.diseaseNephogramsOnmouse = true;
            }
        }

        function setZyMzMoneyNumber() {
            $.ajax({
                type: "POST",
                dataType: "json",
                contentType: "application/json",
                url: 'lsddCharts/queryTodayMzOrZyMoney?lsddId=${map_lsdd_id!}&grade=${grade!}',
                success: function (result) {
                    try {
                        if (result[0] != null && result[0] != "null") {
                            if (lsddChart.size() > 0) {
                                lsddChart.clear();
                            }
                            $.each(result, function (key, val) {
                                lsddChart.put(val.ORGAN_ID, val)
                            });
                        }
                    } catch (e) {
                        console.log(e);
                    }

                }
            });
        }

        function setMap(_cityDate) {
            // cityMap.dispose();
            cityMap = echarts.init(document.getElementById('cityMap'));
            var arrCity = [];
            var data = JSON.stringify(shantouDate);
            $.each($.parseJSON(data).features, function (i, data) {
                var index = i > lsddChart.mapColors.length - 1 ? i - lsddChart.mapColors.length : i;
                var color = lsddChart.mapColors[index];
                var obj = {name: data.properties.name, value: 0, itemStyle: {normal: {areaColor: color}}};
                arrCity.push(obj);
                $.each(lsddChart.mapCityDate, function (j, m) {
                    if (m.name == obj.name) {
                        obj.value = m.value;
                        if (_cityDate != "" && _cityDate[0].name == m.name) {
                            obj.selected = true;
                        } else {
                            obj.selected = false;
                        }
                        return;
                    }
                });
            });
            lsddChart.mapOption.series[0].data = arrCity;
            lsddChart.mapOption.series[2].data = _cityDate;
            cityMap.setOption(lsddChart.mapOption);
            if (!lsddChart.initMapOnClick) {
                lsddChart.initMapOnClick = true;
                cityMap.on('click', function (params) {
                    if (params.data.selected == true) {
                        if (params.seriesIndex == 1) {
                            selectedOrgid = params.data.orgid;
                            var index = $('#shantou_tables').tabs('getTabIndex', $('#shantou_tables').tabs('getSelected'));
                            $("#shantou_window").window('open').window("setTitle", params.data.orgname);
                            searchMZorZYservice(index, selectedOrgid);
                        } else {
                            selectedOrgid = setTitleDate.orgid;
                            var index = $('#shantou_tables').tabs('getTabIndex', $('#shantou_tables').tabs('getSelected'));
                            $("#shantou_window").window('open').window("setTitle", setTitleDate.orgname);
                            searchMZorZYservice(index, selectedOrgid);
                        }

                    }
                });
                cityMap.on('mouseout', function () {
                    clearInterval(clear);
                    clear = setInterval(gongdongTable, 2000);
                });
                cityMap.on('mouseover', function () {
                    clearInterval(clear);
                });
            }
        }

        function queryCityHospitalTotals() {
            $.ajax({
                type: "POST",
                dataType: "json",
                contentType: "application/json",
                url: 'lsddCharts/queryCityHospitalTotals?unitId=${map_lsdd_id!}',
                success: function (result) {
                    try {
                        if (result[0] != null && result[0] != "null") {
                            $("#mzrc").text(number_format(converData(result[0].MZ_NUMBER), 0, ".", ",", ''));
                            $("#zyrc").text(number_format(converData(result[0].ZY_NUMBER), 0, ".", ",", ''));
                            $("#zysr").text(number_format(converData(result[0].ZY_MONEY), 2, ".", ",", '¥'));
                            $("#mzsr").text(number_format(converData(result[0].MZ_MONEY), 2, ".", ",", '¥'));
                            $("#ypfy").text(number_format(converData(result[0].YPFY), 2, ".", ",", '¥'));
                            $("#ylfwfy").text(number_format(converData(result[0].YLFWFY), 2, ".", ",", '¥'));
                            var checkTime = false;
                            if (lsddChart.timeTotalsValue != null) {
                                if (!comparatorValue(result[0].ZY_MONEY, lsddChart.timeTotalsValue[0].ZY_MONEY)) {
                                    $("#zysr_div").attr("class", "zyrczysrTwo");
                                    checkTime = true;
                                }
                                if (!comparatorValue(result[0].MZ_MONEY, lsddChart.timeTotalsValue[0].MZ_MONEY)) {
                                    $("#mzsr_div").attr("class", "mzrcmzsrTwo");
                                    checkTime = true;
                                }
                                if (!comparatorValue(result[0].YPFY, lsddChart.timeTotalsValue[0].YPFY)) {
                                    $("#ypfy_div").attr("class", "mzrcmzsrTwo");
                                    checkTime = true;
                                }
                                if (!comparatorValue(result[0].YLFWFY, lsddChart.timeTotalsValue[0].YLFWFY)) {
                                    $("#ylfwfy_div").attr("class", "zyrczysrTwo");
                                    checkTime = true;
                                }
                            }
                            if (checkTime) {
                                setTimeout(function () {
                                    $("#zysr_div").attr("class", "zyrczysr");
                                    $("#mzsr_div").attr("class", "mzrcmzsr");
                                    $("#ypfy_div").attr("class", "mzrcmzsr");
                                    $("#ylfwfy_div").attr("class", "zyrczysr");
                                }, 3000);
                            }
                            lsddChart.timeTotalsValue = result;
                        }
                    } catch (e) {
                        console.log("统计住院费用、医疗费用、住院人次接口出错" + e)
                    }
                }
            });
        }

        //访问健康档案浏览器
        function openHrbc(_idnum) {
            if (null == _idnum || '' == _idnum) {
                alert('身份证为空!');
                return;
            }
            lsddChart.ajaxCharts('lsddCharts/queryhrbcData', function (result) {
                try {
                    var hrbcData = eval("(" + result.hrbcObj + ")");
                    if (typeof(hrbcData.mpi) != 'undefined') {
                        window.open(result.hrbcURL + "?idnum=" + _idnum + "&mpi=" + hrbcData.mpi + "&token=" + hrbcData.token);
                    }
                } catch (e) {
                    console.log("'访问健康档案浏览器报错500" + e);
                }
            });
        }

        function createShanTouTableDate(_object, _tableDate) {
            _object.empty();
            if (_tableDate[0] != null && _tableDate[0] != "null") {
                $.each(_tableDate, function (key, val) {
                    if (key % 2 == 0) {
                        _object.append("<tr class='odd'><td  style='display: none'>" + val.ORGAN_ID + "</td><td  style='display: none'>" + val.ADMINISTRATIVE_ID + "</td><td style='text-align: left;' >" + val.ORGAN_NAME + "</td><td >" + number_format(converData(val.MZNUMBERTODAY), 0, ".", ",", '') + "</td><td>" + number_format(converData(val.MZMONEYTODAY), 2, ".", ",", '¥') + "</td><td>" + number_format(converData(val.ZYNUMBERTODAY), 0, ".", ",", '') + "</td><td>" + number_format(converData(val.ZYMONEYTODAY), 2, ".", ",", '¥') + "</td> </tr>");

                    } else {
                        _object.append("<tr class='even' ><td  style='display: none'>" + val.ORGAN_ID + "</td><td  style='display: none'>" + val.ADMINISTRATIVE_ID + "</td><td style='text-align: left;'  >" + val.ORGAN_NAME + "</td><td >" + number_format(converData(val.MZNUMBERTODAY), 0, ".", ",", '') + "</td><td>" + number_format(converData(val.MZMONEYTODAY), 2, ".", ",", '¥') + "</td><td>" + number_format(converData(val.ZYNUMBERTODAY), 0, ".", ",", '') + "</td><td>" + number_format(converData(val.ZYMONEYTODAY), 2, ".", ",", '¥') + "</td> </tr>");
                    }

                });
            } else {
                _object.append("<tr style=\"height: 265px;\"><td colspan=\"5\"></td></tr>");
            }
        }

        function converData(_value) {
            if (_value == null || _value == "null" || _value == "") {
                return 0;
            }
            return _value;
        }

        function converDataString(_value) {
            if (_value == null || _value == "null" || _value == "") {
                return "";
            }
            return _value;
        }

        function gongdongTable() {
            var field = text.find("tr:first");
            var len = text.find("tr").length;
            var high = field.height();
            if (len > 0 & high != null && high != "null") {
                var indexLength = Math.trunc(len / 2)
                var index = indexLength < 2 ? indexLength : 2;
                var updatelenth = len > 8 ? 8 : len;
                text.animate({marginTop: -high + "px"}, 600, function () {
                    field.css("marginTop", 0).appendTo(text);
                    text.css("marginTop", 0);
                    text.find("tr").eq(index).siblings().css({"background": "", "color": ""})
                    text.find("tr").eq(index).css({"background": "rgba(11,98,195,0.6)", "color": "#FFFFFF"})
                    for (var i = 0; i < updatelenth && i < lsddChart.size(); i++) {
                        var val = lsddChart.get(text.find("tr").eq(i).children('td:eq(0)').text());
                        text.find("tr").eq(i).children('td:eq(3)').text(number_format(converData(val.MZNUMBERTODAY), 0, ".", ",", ''));
                        text.find("tr").eq(i).children('td:eq(4)').text(number_format(converData(val.MZMONEYTODAY), 2, ".", ",", '¥'));
                        text.find("tr").eq(i).children('td:eq(5)').text(number_format(converData(val.ZYNUMBERTODAY), 0, ".", ",", ''));
                        text.find("tr").eq(i).children('td:eq(6)').text(number_format(converData(val.ZYMONEYTODAY), 2, ".", ",", '¥'));
                    }
                    var selectMap = convertData(text.find("tr").eq(index).children('td:eq(1)').text());
                    setTitleDate.orgid = text.find("tr").eq(index).children('td:eq(0)').text();
                    setTitleDate.orgname = text.find("tr").eq(index).children('td:eq(2)').text();
                    setMap(selectMap);
                })
            }
        }


        function convertData(_object) {
            try {
                var res = [];
                var cityCodeSub = _object.substring(0, 6).concat("000000");
                var cityName = lsddChart.geoCoordCity[cityCodeSub];
                var geoCoord = lsddChart.geoCoordMap[_object];
                if (!geoCoord) {
                    geoCoord = lsddChart.geoCoordMap[cityCodeSub];
                }
                res.push({
                    name: cityName,
                    selected: true,
                    value: geoCoord.concat(_object)
                });
                return res;
            } catch (e) {
                console.log("格式化数据错误" + e)
            }
            return '';
        }

        function convertDataTow(_arrayObject) {
            try {
                var res = [];
                $.each(_arrayObject, function (key, val) {
                    var _object = val.value.ADMINISTRATIVE_ID;
                    var cityCodeSub = _object.substring(0, 6).concat("000000");
                    var cityName = lsddChart.geoCoordCity[cityCodeSub];
                    var geoCoord = lsddChart.geoCoordMap[_object];
                    if (typeof geoCoord == "undefined") {
                        //  console.log(val.value.ADMINISTRATIVE_NAME+"======================------"+_object);
                        return true;
                    }
                    if (!geoCoord) {
                        geoCoord = lsddChart.geoCoordMap[cityCodeSub];
                    }
                    res.push({
                        name: cityName, selected: true, orgid: val.value.ORGAN_ID,
                        orgname: val.value.ORGAN_NAME,
                        value: geoCoord.concat(_object)
                    });
                });
                return res;
            } catch (e) {

                console.log("格式化数据错误" + e)

            }
            return '';
        }


        function number_format(number, decimals, dec_point, thousands_sep, mark) {
            number = (number + '').replace(/[^0-9+-Ee.]/g, '');
            var n = !isFinite(+number) ? 0 : +number,
                    prec = !isFinite(+decimals) ? 0 : Math.abs(decimals),
                    sep = (typeof thousands_sep === 'undefined') ? ',' : thousands_sep,
                    dec = (typeof dec_point === 'undefined') ? '.' : dec_point,
                    s = '',
                    toFixedFix = function (n, prec) {
                        var k = Math.pow(10, prec);
                        return '' + Math.ceil(n * k) / k;
                    };
            s = (prec ? toFixedFix(n, prec) : '' + Math.round(n)).split('.');
            var re = /(-?\d+)(\d{3})/;
            while (re.test(s[0])) {
                s[0] = s[0].replace(re, "$1" + sep + "$2");
            }
            if ((s[1] || '').length < prec) {
                s[1] = s[1] || '';
                s[1] += new Array(prec - s[1].length + 1).join('0');
            }
            if (mark != '' && mark != null && typeof(mark) != 'undefined') {
                return mark.concat(s.join(dec));
            }
            return s.join(dec);
        }

        function searchMZorZYservice(_index, _selectedOrgid) {
            if (_index == 0) {
                mzservice(_selectedOrgid);
            } else {
                zyservice(_selectedOrgid);
            }
        }


        function comparatorValue(_value1, _value2) {
            if (converData(_value1) == converData(_value2)) {
                return true;
            }
            return false;
        }

        function mzservice(_selectedOrgid) {
            $("#mzservice").gridView({
                singleton: true,
                width: 1500,
                pageSize: 20,
                height: 485,
                subGrid: true,
                url: '${base}/lsddCharts/queryMzService',
                params: {
                    orgid: _selectedOrgid
                },
                columns: [
                    {field: 'idnum', hidden: true},
                    {field: 'status', hidden: true},
                    {field: 'ghlsh', hidden: true},
                    {field: 'hzxm', title: '患者姓名', width: 100},
                    {field: 'jzsj', title: '就诊时间', width: 150},
                    {
                        field: 'sfz', title: '身份证', width: 150, formatter: function (value, row, index) {
                            return lsddChart.jumpToHrbs(value, row);

                        }
                    },
                    {field: 'jzzd', title: '就诊诊断', width: 150, showTips: true, tipLength: 11},
                    {field: 'fylx', title: '费用类型', width: 150},
                    {field: 'ywmc', title: '项目名称', width: 200, showTips: true, tipLength: 14},
                    {
                        field: 'mxxmdj', title: '单价(元)', width: 100, align: 'right', formatter: function (value) {
                            if (value != null && value != "") {
                                return number_format(value, 2, ".", ",", '¥');
                            }
                            return "";
                        }
                    },
                    {field: 'mxxmsl', title: '数量', width: 100},
                    {
                        field: 'mxxmje', title: '总金额(元)', width: 100, align: 'right', formatter: function (value) {
                            if (value != null && value != "") {
                                return number_format(value, 2, ".", ",", '¥');
                            }
                            return "";
                        }
                    },
                    {field: 'jzysxm', title: '接诊医生', width: 100},
                    {field: 'jzksmc', title: '接诊科室', width: 100},
                    {field: 'jzlsh', title: '就诊流水号', width: 100}
                ],
                onBeforeExpand: function (row, callback) {
                    $.post('${base}/lsddCharts/queryMzServicexx?orgid=' + selectedOrgid + '&jzlsh=' + row.jzlsh + '&ghlsh=' + row.ghlsh, function (data) {
                        if (data) {
                            callback(data);
                        }
                    }, "JSON");
                }
            });
        }

        function mzServiceDetail() {
            qxMZ = $('#qxCodeValueMZ').combobox('getValue');
            xzMZ = $('#xzCodeValueMZ').combobox('getValue');
            jgMZ = $('#jgCodeValueMZ').combobox('getValue');
            startDataMZ = $('#startData').val();
            endDataMZ = $('#endData').val();
            $("#mzServiceDetail").gridView({
                singleton: true,
                width: 1700,
                height: 485,
                pageSize: 20,
                subGrid: true,
                url: '${base}/lsddCharts/queryMzServiceSearch',
                params: {
                    qxId: qxMZ,
                    xzId: xzMZ,
                    orgid: jgMZ,
                    startDate: startDataMZ,
                    endDate: endDataMZ
                },
                columns: [
                    {field: 'idnum', hidden: true},
                    {field: 'qxmc', title: '区县', width: 100},
                    {field: 'xzmc', title: '乡镇', width: 100},
                    {field: 'jgmc', title: '机构名称', width: 150},
                    {field: 'qxdm', title: '区县id', hidden: true},
                    {field: 'xzdm', title: '乡镇id', hidden: true},
                    {field: 'jgdm', title: '机构id', hidden: true},
                    {field: 'hzxm', title: '患者姓名', width: 100},
                    {field: 'jzsj', title: '就诊时间', width: 150},
                    {field: 'status', hidden: true},
                    {
                        field: 'sfz', title: '身份证', width: 150, formatter: function (value, row, index) {
                            return lsddChart.jumpToHrbs(value, row);
                        }
                    },
                    {field: 'jzzd', title: '就诊诊断', width: 150, showTips: true, tipLength: 10},
                    {field: 'fylx', title: '费用类型', width: 100},
                    {field: 'ywmc', title: '项目名称', width: 100, showTips: true, tipLength: 7},
                    {
                        field: 'mxxmdj', title: '单价(元)', width: 100, align: 'right', formatter: function (value) {
                            if (value != null && value != "") {
                                return number_format(value, 2, ".", ",", '¥');
                            }
                            return "";
                        }
                    },
                    {field: 'mxxmsl', title: '数量', width: 100},
                    {
                        field: 'mxxmje', title: '总金额(元)', width: 100, align: 'right', formatter: function (value) {
                            if (value != null && value != "") {
                                return number_format(value, 2, ".", ",", '¥');
                            }
                            return "";
                        }
                    },
                    {field: 'jzysxm', title: '接诊医生', width: 100},
                    {field: 'jzksmc', title: '接诊科室', width: 100},
                    {field: 'jzlsh', title: '就诊流水号', width: 100}
                ],
                onBeforeExpand: function (row, callback) {
                    $.post('${base}/lsddCharts/queryMzServiceDetailxx?orgid=' + row.jgdm + '&jzlsh=' + row.jzlsh + '&hzxm=' + row.hzxm, function (data) {
                        if (data) {
                            callback(data);
                        }
                    }, "JSON");
                }
            });

        }

        function zyservice(_selectedOrgid) {
            $("#zyservice").gridView({
                singleton: true,
                width: 1500,
                height: 485,
                pageSize: 20,
                subGrid: true,
                url: '${base}/lsddCharts/queryZyService',
                params: {
                    orgid: _selectedOrgid
                },
                columns: [
                    {field: 'idnum', hidden: true},
                    {field: 'status', hidden: true},
                    {field: 'hzxm', title: '患者姓名', width: 100},
                    {field: 'ryrq', title: '入院时间', width: 150},
                    {
                        field: 'sfz', title: '身份证', width: 150, formatter: function (value, row, index) {
                            return lsddChart.jumpToHrbs(value, row);
                        }
                    },
                    {field: 'zdmc', title: '就诊诊断', width: 200, showTips: true, tipLength: 14},
                    {field: 'fylx', title: '费用类型', width: 150},
                    {field: 'xmmc', title: '项目名称', width: 200, showTips: true, tipLength: 14},
                    {
                        field: 'dj', title: '单价(元)', width: 100, align: 'right', formatter: function (value) {
                            if (value != null && value != "") {
                                return number_format(value, 2, ".", ",", '¥');
                            }
                            return "";
                        }
                    },
                    {field: 'sl', title: '数量', width: 100},
                    {
                        field: 'je', title: '总金额(元)', width: 100, align: 'right', formatter: function (value) {
                            if (value != null && value != "") {
                                return number_format(value, 2, ".", ",", '¥');
                            }
                            return "";
                        }
                    },
                    {field: 'ks', title: '住院科室', width: 100},
                    {field: 'zylsh', title: '住院号', width: 150},
                ],
                onBeforeExpand: function (row, callback) {
                    var data;
                    lsddChart.ajaxCharts('${base}/lsddCharts/queryZyServicexx?orgid=' + selectedOrgid + '&zylsh=' + row.zylsh + '&hzxm=' + row.hzxm, function (result) {
                        data = result;
                    });
                    callback(data);
                }
            });
        }


        function zyServiceDetail() {
            qxZY = $('#qxCodeValueZY').combobox('getValue');
            xzZY = $('#xzCodeValueZY').combobox('getValue');
            jgZY = $('#jgCodeValueZY').combobox('getValue');
            startDataZY = $('#startDataZY').val();
            endDataZY = $('#endDataZY').val();
            $("#zyServiceDetail").gridView({
                singleton: true,
                width: 1650,
                height: 485,
                pageSize: 20,
                subGrid: true,
                url: '${base}/lsddCharts/queryZyServiceSearch',
                params: {
                    qxId: qxZY,
                    xzId: xzZY,
                    orgid: jgZY,
                    startDate: startDataZY,
                    endDate: endDataZY
                },
                columns: [
                    {field: 'idnum', hidden: true},
                    {field: 'status', hidden: true},

                    {field: 'qxmc', title: '区县', width: 100},
                    {field: 'xzmc', title: '乡镇', width: 100},
                    {field: 'jgmc', title: '机构名称', width: 150},
                    {field: 'qxdm', title: '区县id', hidden: true},
                    {field: 'xzdm', title: '乡镇id', hidden: true},
                    {field: 'jgdm', title: '机构id', hidden: true},

                    {field: 'hzxm', title: '患者姓名', width: 100},
                    {field: 'ryrq', title: '入院时间', width: 150},
                    {
                        field: 'sfz', title: '身份证', width: 100, formatter: function (value, row, index) {
                            return lsddChart.jumpToHrbs(value, row);
                        }
                    },
                    {field: 'zdmc', title: '就诊诊断', width: 150, showTips: true, tipLength: 10},
                    {field: 'fylx', title: '费用类型', width: 150},
                    {field: 'xmmc', title: '项目名称', width: 100, showTips: true, tipLength: 7},
                    {
                        field: 'dj', title: '单价(元)', width: 100, align: 'right', formatter: function (value) {
                            if (value != null && value != "") {
                                return number_format(value, 2, ".", ",", '¥');
                            }
                            return "";
                        }
                    },
                    {field: 'sl', title: '数量', width: 100},
                    {
                        field: 'je', title: '总金额(元)', width: 100, align: 'right', formatter: function (value) {
                            if (value != null && value != "") {
                                return number_format(value, 2, ".", ",", '¥');
                            }
                            return "";
                        }
                    },
                    {field: 'ks', title: '住院科室', width: 100},
                    {field: 'zylsh', title: '住院号', width: 150},
                ],
                onBeforeExpand: function (row, callback) {
                    $.post('${base}/lsddCharts/queryZyServiceDetailxx?orgid=' + row.jgdm + '&zylsh=' + row.zylsh + '&hzxm=' + row.hzxm, function (data) {
                        if (data) {
                            callback(data);
                        }
                    }, "JSON");
                }
            });
        }


        function mz_setOrganizationAndUnit(_orgData) {
            lsddChart.org_unitData = _orgData;
            if (_orgData.length > 0) {
                lsddChart.orgData.push({orgid: "all", orgname: "全部", 'selected': true});
                lsddChart.unitData.push({unitid: "all", unitname: "全部", 'selected': true});
                $.each(_orgData, function (key, val) {
                    lsddChart.orgData.push({orgid: val.ORGID, orgname: val.SHORTNAME});
                    if (val.GRADE && val.GRADE === 3) {
                        lsddChart.unitData.push({unitid: val.UNITID, unitname: val.NAME});
                    }
                });
                lsddChart.unitData = distinctUnit(lsddChart.unitData);
                $('#xzCodeValueMZ').combobox({
                    valueField: 'unitid',
                    textField: 'unitname',
                    data: lsddChart.unitData,
                    onChange: function (newValue, oldValue) {
                        if ("all" !== newValue) {
                            $('#jgCodeValueMZ').combobox('clear');
                            lsddChart.orgDataChangeTwo = [];
                            lsddChart.orgDataChangeTwo.push({orgid: "all", orgname: "全部"});
                            $.each(lsddChart.org_unitData, function (key, val) {
                                if (comparatorValue(val.UNITID.substr(0, 9), newValue.substr(0, 9))) {
                                    lsddChart.orgDataChangeTwo.push({orgid: val.ORGID, orgname: val.SHORTNAME});
                                }
                            });
                            $("#jgCodeValueMZ").combobox({data: lsddChart.orgDataChangeTwo});
                        } else {
                            var zyvalue = $('#qxCodeValueMZ').combobox('getValue');
                            if (!comparatorValue("all", zyvalue) && !comparatorValue(3,${grade!})) {
                                $("#jgCodeValueMZ").combobox({data: lsddChart.orgDataChange});
                            } else {
                                $("#jgCodeValueMZ").combobox({data: lsddChart.orgData});
                            }
                        }
                        $('#jgCodeValueMZ').combobox('select', 'all');
                    }
                });
                $('#jgCodeValueMZ').combobox({
                    valueField: 'orgid',
                    textField: 'orgname',
                    data: lsddChart.orgData
                });
            }
        }

        function distinctUnit(arr) {
            for (var i = 0; i < arr.length; i++) {
                for (var j = i + 1; j < arr.length; j++) {
                    if (arr[i].unitid == arr[j].unitid) {
                        arr.splice(j, 1);
                        j--;
                    }
                }
            }
            return arr;
        }


        function zy_setOrganizationAndUnit(_orgData) {
            lsddChart.org_unitData = _orgData;
            if (_orgData.length > 0) {
                lsddChart.orgData.push({orgid: "all", orgname: "全部", 'selected': true});
                lsddChart.unitData.push({unitid: "all", unitname: "全部", 'selected': true});
                $.each(_orgData, function (key, val) {
                    lsddChart.orgData.push({orgid: val.ORGID, orgname: val.SHORTNAME});
                    if (val.GRADE && val.GRADE === 3) {
                        lsddChart.unitData.push({unitid: val.UNITID, unitname: val.NAME});
                    }
                });
                lsddChart.unitData = distinctUnit(lsddChart.unitData);
                $('#xzCodeValueZY').combobox({
                    valueField: 'unitid',
                    textField: 'unitname',
                    data: lsddChart.unitData,
                    onChange: function (newValue, oldValue) {
                        if (!comparatorValue("all", newValue)) {
                            $('#jgCodeValueZY').combobox('clear');
                            lsddChart.orgDataChangeTwoZY = [];
                            lsddChart.orgDataChangeTwoZY.push({orgid: "all", orgname: "全部"});
                            $.each(lsddChart.org_unitData, function (key, val) {
                                if (comparatorValue(val.UNITID.substr(0, 9), newValue.substr(0, 9))) {
                                    lsddChart.orgDataChangeTwoZY.push({orgid: val.ORGID, orgname: val.SHORTNAME});
                                }
                            });
                            $("#jgCodeValueZY").combobox({data: lsddChart.orgDataChangeTwoZY});
                        } else {
                            var zyvalue = $('#qxCodeValueZY').combobox('getValue');
                            if (!comparatorValue("all", zyvalue) && !comparatorValue(3,${grade!})) {
                                $("#jgCodeValueZY").combobox({data: lsddChart.orgDataChangeZY});
                            } else {
                                $("#jgCodeValueZY").combobox({data: lsddChart.orgData});
                            }
                        }
                        $('#jgCodeValueZY').combobox('select', 'all');
                    }
                });
                $('#jgCodeValueZY').combobox({
                    valueField: 'orgid',
                    textField: 'orgname',
                    data: lsddChart.orgData
                });
            }
        }

        function mz_initUnitCombobox() {
            $('#qxCodeValueMZ').combobox({
                onChange: function (newValue, oldValue) {
                    $('#jgCodeValueMZ').combobox('clear');
                    $('#xzCodeValueMZ').combobox('clear');
                    if ("all" != newValue) {
                        lsddChart.orgDataChange = [];
                        lsddChart.unitDataChange = [];
                        lsddChart.orgDataChange.push({orgid: "all", orgname: "全部"});
                        lsddChart.unitDataChange.push({unitid: "all", unitname: "全部"});
                        $.each(lsddChart.org_unitData, function (key, val) {
                            if (comparatorValue(val.UNITID.substr(0, 6), newValue.substr(0, 6))) {
                                lsddChart.orgDataChange.push({orgid: val.ORGID, orgname: val.SHORTNAME});
                                if (val.GRADE && val.GRADE === 3) {
                                    lsddChart.unitDataChange.push({unitid: val.UNITID, unitname: val.NAME});
                                }
                            }
                        });
                        lsddChart.unitDataChange = distinctUnit(lsddChart.unitDataChange);
                        $("#jgCodeValueMZ").combobox({data: lsddChart.orgDataChange});
                        $("#xzCodeValueMZ").combobox({data: lsddChart.unitDataChange});
                    } else {
                        $("#jgCodeValueMZ").combobox({data: lsddChart.orgData});
                        $("#xzCodeValueMZ").combobox({data: lsddChart.unitData});
                    }

                    $('#xzCodeValueMZ').combobox('select', 'all');
                    $('#jgCodeValueMZ').combobox('select', 'all');
                }
            });
        }

        function zy_initUnitCombobox() {
            $('#qxCodeValueZY').combobox({
                onChange: function (newValue, oldValue) {
                    $('#jgCodeValueZY').combobox('clear');
                    $('#xzCodeValueZY').combobox('clear');
                    if (!comparatorValue("all", newValue)) {
                        lsddChart.orgDataChangeZY = [];
                        lsddChart.unitDataChangeZY = [];
                        lsddChart.orgDataChangeZY.push({orgid: "all", orgname: "全部"});
                        lsddChart.unitDataChangeZY.push({unitid: "all", unitname: "全部"});
                        $.each(lsddChart.org_unitData, function (key, val) {
                            if (comparatorValue(val.UNITID.substr(0, 6), newValue.substr(0, 6))) {
                                lsddChart.orgDataChangeZY.push({orgid: val.ORGID, orgname: val.SHORTNAME});
                                if (val.GRADE && val.GRADE === 3) {
                                    lsddChart.unitDataChangeZY.push({unitid: val.UNITID, unitname: val.NAME});
                                }
                            }
                        });
                        lsddChart.unitDataChangeZY = distinctUnit(lsddChart.unitDataChangeZY);
                        $("#jgCodeValueZY").combobox({data: lsddChart.orgDataChangeZY});
                        $("#xzCodeValueZY").combobox({data: lsddChart.unitDataChangeZY});
                    } else {
                        $("#jgCodeValueZY").combobox({data: lsddChart.orgData});
                        $("#xzCodeValueZY").combobox({data: lsddChart.unitData});
                    }

                    $('#jgCodeValueZY').combobox('select', 'all');
                    $('#xzCodeValueZY').combobox('select', 'all');
                }
            });
        }


    </script>
    <style type="text/css">
        .table_two {
            border: 1px solid rgba(0, 0, 0, 0.2);
        }

        .table_two thead tr th {
            background-color: #0D2E4E;
            padding: 6px 4px 6px 3px;
            font-size: 16px;
            color: #FFFFFF;
            font-weight: bold;
            border-bottom: 1px solid rgba(0, 0, 0, 0.2);
            text-align: right;
        }

        .table_two tbody tr td {
            text-align: right;
            font-size: 14px;
            padding: 6px 4px 6px 4px;
        }

        .odd {
            color: #BBCFDD;
            background: rgba(6, 48, 104, 0.3);
        }

        .even {
            color: ;
            color: #BBCFDD;
            background: rgba(3, 77, 127, 0.3);
        }

        .mzrcmzsr {
            height: 50px;
            width: 100%;
            text-align: center;
            font-size: 15px;
            color: #00AFFF;
            padding-top: 10px;
        }

        .mzrcmzsrTwo {
            height: 50px;
            width: 100%;
            text-align: center;
            font-size: 17px;
            color: #00AFFF;
            padding-top: 10px;
            font-weight: bold;
        }

        .zyrczysr {
            height: 50px;
            width: 100%;
            text-align: center;
            font-size: 15px;
            color: #00AFFF;
        }

        .zyrczysrTwo {
            height: 50px;
            width: 100%;
            text-align: center;
            font-size: 17px;
            color: #00AFFF;
            font-weight: bold;
        }

        .tip {
            width: 200px;
            padding: 8px;
            background: rgba(35, 35, 35, 0.7);
            color: white;
            font-size: 13px;
        }
    </style>
</head>
<body style="margin: auto;padding: auto;text-align: center">
<div class="container-fluid">
    <div class="row"
         style="background: url('${base}/images/top4.png') no-repeat; background-size:100% 100%;margin-bottom: 5px;">
        <div style=" height:40px;width: 100%;font-size: 25px;font-weight: bold;color:white;text-align: center; font-family:'楷体';">
        ${city_name!}卫生信息实时管理系统
        </div>
    </div>
    <div class="row" style="height: 10px;">&nbsp;</div>
    <div class="row" style="margin: auto;padding: auto;text-align: center;">
        <div class="col-md-4" style="width:32.5%;">
            <div style=" width:100%;height:300px;margin: auto;padding: auto;text-align: center;">
                <div class="col-md-4"
                     style="width:32%;  background: url('${base}/images/lsddTopOne.png') no-repeat; background-size:100% 100%;position: relative;">
                    <div style="width: 99.5%;height:40px; position: absolute; top: 0px;left:2px; background:rgba(0,175,255,1);opacity:0.1;">
                    </div>
                    <div style=" width:100%;height:285px;">
                        <div style="width: 100%;text-align: center;color: white;font-size: 16px;font-weight: bold;padding: 10px 0px 10px 5px; ">
                            门诊<font style="font-size: 18px;color:#00AFFF;opacity:0.5;">/</font>出院人次
                        </div>
                        <div style="height: 50px;width: 100%;text-align: center;font-size: 15px;color: #FFFFFF;padding-top: 25px;">
                            门诊人次
                        </div>
                        <div id="mzrc_div" class="mzrcmzsr"><span id="mzrc"></span></div>
                        <div style="height: 50px;width: 100%;text-align: center;font-size: 15px;color: #FFFFFF;padding-top: 10px;">
                            出院人次
                        </div>
                        <div id="zyrc_div" class="zyrczysr"><span id="zyrc"></span></div>
                    </div>
                </div>
                <div class="col-md-4"
                     style="width:32%;margin-left: 1%; background: url('${base}/images/lsddTopOne.png') no-repeat; background-size:100% 100%;position: relative;">
                    <div style="width: 99.5%;height:40px; position: absolute; top: 0px;left:2px; background:rgba(0,175,255,1);opacity:0.1;">
                    </div>
                    <div style=" width:100%;height:285px;">
                        <div style="width: 100%;text-align: center;color: white;font-size: 16px;font-weight: bold;padding: 10px 0px 10px 5px; ">
                            门诊<font style="font-size: 18px;color:#00AFFF;opacity:0.5;">/</font>住院费用
                        </div>
                        <div style="height: 50px;width: 100%;text-align: center;font-size: 15px;color: #FFFFFF;padding-top: 25px;">
                            门诊费用
                        </div>
                        <div id="mzsr_div" class="mzrcmzsr"><span id="mzsr"></span></div>
                        <div style="height: 50px;width: 100%;text-align: center;font-size: 15px;color: #FFFFFF;padding-top: 10px;">
                            住院费用
                        </div>
                        <div id="zysr_div" class="zyrczysr"><span id="zysr"></span></div>
                    </div>
                </div>
                <div class="col-md-4"
                     style="width:33%;margin-left: 1%; background: url('${base}/images/lsddTopOne.png') no-repeat; background-size:100% 100%;position: relative;">
                    <div style="width: 99%;height:40px; position: absolute; top: 0px;left:2px; background:rgba(0,175,255,1);opacity:0.1;">
                    </div>
                    <div style=" width:100%;height:285px;">
                        <div style="width: 100%;text-align: center;color: white;font-size: 16px;font-weight: bold;padding: 10px 0px 10px 5px; ">
                            药品<font style="font-size: 18px;color:#00AFFF;opacity:0.5;">/</font>医疗费用
                        </div>
                        <div style="height: 50px;width: 100%;text-align: center;font-size: 15px;color: #FFFFFF;padding-top: 25px;">
                            药品费用
                        </div>
                        <div id="ypfy_div" class="mzrcmzsr"><span id="ypfy"></span></div>
                        <div style="height: 50px;width: 100%;text-align: center;font-size: 15px;color: #FFFFFF;padding-top: 10px;">
                            医疗服务费用
                        </div>
                        <div id="ylfwfy_div" class="zyrczysr"><span id="ylfwfy"></span></span></div>
                    </div>
                </div>

            </div>
        </div>
        <div class="col-md-4"
             style=" width:33%;margin-left: 1%; background: url('${base}/images/lsddTopTwo.png') no-repeat; background-size:100% 100%;position: relative;">
            <div style="width:100%;height:320px;margin: auto;padding: auto;text-align: center;"
            ">
            <div style="height: 10px;">&nbsp;</div>
            <div style="height: 300px; display: block; overflow: hidden; width: 100%;">
                <table id="shantouylmz_table" class="table_two table-hovers" cellspacing="0" cellpadding="0"
                       style="width: 100%;height: 300px;  overflow: hidden;">
                    <thead>
                    <tr>
                        <th width="32%" style="text-align:left;">卫生机构</th>
                        <th width="16%">门诊人次</th>
                        <th width="18%">门诊总额</th>
                        <th width="16%">出院人次</th>
                        <th width="18%">住院总额</th>
                    </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>
        </div>
    </div>
    <div class="col-md-4"
         style="position: relative;width:32.5%;margin-left: 1%;background: url('${base}/images/lsddTopTwo.png') no-repeat; background-size:100% 100%;">
        <div style="width: 99.5%;height:40px; position: absolute; top: 0px;left:2px; background:rgba(0,175,255,1);opacity:0.1; ">
        </div>
        <div style="width: 100%;text-align: center;color: white;font-size: 17px;font-weight: bold;padding: 10px;">
        ${city_name!}医疗机构分布图
        </div>
        <div id="cityMap" style="width:100%;height:320px; margin-top: -45px;"></div>
    </div>
</div>
<div class="row" style="height: 10px;"></div>
<div class="row" style="margin: auto;padding: auto;text-align: center;">
    <div class="col-md-4"
         style=" width:32.5%;background: url('${base}/images/lsddCenterTwo.png') no-repeat; background-size:100% 100%;position: relative;">
        <div style="width: 99.5%;height:40px; position: absolute; top: 0px;left:2px; background:rgba(0,175,255,1);opacity:0.1; ">
        </div>
        <div style="width: 100%;text-align: center;color: white;font-size: 17px;font-weight: bold;padding: 10px;">
            建档率与签约率
        </div>
        <div id="jdl_qyl" style="width:100%;height:330px; margin-top: -20px;"></div>
    </div>
    <div class="col-md-4"
         style=" width:33%;margin-left: 1%; background: url('${base}/images/lsddCenterTwo.png') no-repeat; background-size:100% 100%;position: relative;">
        <div style="width: 99.5%;height:40px; position: absolute; top: 0px;left:2px; background:rgba(0,175,255,1);opacity:0.1; ">
        </div>
        <div style="width: 100%;text-align: center;color: white;font-size: 17px;font-weight: bold;padding: 10px;">
            当日医疗机构费用
        </div>
        <div id="qsdtjgsr" style="width:100%;height:330px; margin-top: -20px;"></div>
    </div>
    <div class="col-md-4"
         style=" width:32.5%;margin-left: 1%; background: url('${base}/images/lsddCenterTwo.png') no-repeat; background-size:100% 100%;position: relative;">
        <div style="width: 99.5%;height:40px; position: absolute; top: 0px;left:2px; background:rgba(0,175,255,1);opacity:0.1; ">
        </div>
        <div style="width: 100%;text-align: center;color: white;font-size: 17px;font-weight: bold;padding: 10px;">
            当日疾病云图
        </div>
        <div id="qsdtjjbyt" style="width:100%;height:330px; margin-top: -20px;"></div>
    </div>
</div>
<div class="row" style="height:10px;"></div>
<div class="row" style="margin: auto;padding: auto;text-align: center;">
    <div class="col-md-6"
         style=" width:49.5%;background: url('${base}/images/ylbjt_tow.png') no-repeat; background-size:100% 100%;position: relative;">
        <div style="width: 99.5%;height:40px; position: absolute; top: 0px;left:2px; background:rgba(0,175,255,1);opacity:0.1; ">
        </div>
        <div style="width: 100%;text-align: center;color: white;font-size: 17px;font-weight: bold;padding: 10px;">
            门诊业务时间点统计图
        </div>
        <div id="mzyw_total" style="width:100%;height:300px;margin-top: -30px;"></div>
    </div>
    <div class="col-md-6"
         style="width:49.5%; margin-left: 1%; background: url('${base}/images/ylbjt_tow.png') no-repeat; background-size:100% 100%;position: relative;">
        <div style="width: 99.5%;height:40px; position: absolute; top: 0px;left:2px; background:rgba(0,175,255,1);opacity:0.1; ">
        </div>
        <div style="width: 100%;text-align: center;color: white;font-size: 17px;font-weight: bold;padding: 10px;">
            住院业务时间点统计图
        </div>
        <div id="zyyw_total" style="width:100%;height:300px; margin-top: -30px;"></div>
    </div>
</div>
<div class="row" style="height: 10px;"></div>
<div class="row">
    <div id="shantou_window" class="easyui-window"
         style="width:1560px; height: 650px;padding: 0px; display: none;text-align: center;"
         data-options=" cache:false, collapsible:false,minimizable:false,maximizable:false,resizable:false,shadow:false,closed:true">
        <div id="shantou_tables" class="easyui-tabs" style="width: 100%; height: 100%;">
            <div title="门诊服务" style="display:none;padding: 0px;margin: auto;padding: 0px;">
                <table id="mzservice"></table>
            </div>
            <div title="住院服务" style="display:none;padding: 0px;margin: 0px;margin: auto;padding: 0px;">
                <table id="zyservice"></table>
            </div>
        </div>
    </div>
    <div id="shantouMZservice_window" class="easyui-window"
         style="width:1758px; height: 660px;padding: 0px; display: none;"
         data-options=" cache:false, collapsible:false,minimizable:false,maximizable:false,resizable:false,shadow:false,closed:true">
        <div style=" margin:8px; margin-left:20px; text-align: left;">
            <form id="mz_service_form">
                <span style="font-size: 15px;font-weight: 700px">区县:</span>
                <select id="qxCodeValueMZ" class="easyui-combobox" style="width:200px;">
                </select>
                <span style="font-size: 15px;font-weight: 700px">乡镇:</span><select id="xzCodeValueMZ"
                                                                                   class="easyui-combobox"
                                                                                   style="width:200px; "></select>
                <span style="font-size: 15px;font-weight: 700px">机构:</span><select id="jgCodeValueMZ"
                                                                                   class="easyui-combobox"
                                                                                   style="width:250px;"></select>
            <#--<span style="font-size: 15px;font-weight: 700px">日期:</span> <input  id="startData" class="easyui-datetimebox" value="new Date().Format('yyyy-MM-dd');"  data-options="formatter:converDate,showSeconds: false"  style="width:200px">-->
            <#--<span style="font-size: 15px;font-weight: 700px">至:</span> <input  id="endData" class="easyui-datetimebox" value="new Date().Format('yyyy-MM-dd');"  data-options="formatter:converDate,showSeconds: false"  style="width:200px">-->
                <a href="javascript:void(0);" class="easyui-linkbutton searchBt" iconCls="icon-search"
                   style=" margin-left: -5px;" onclick="mzServiceDetail()">查询</a>
                <a class="easyui-linkbutton resetBt" href="javascript:void(0)" iconCls="icon-reset"
                   onclick="$('#qxCodeValueMZ').combobox('select','all');  $('#xzCodeValueMZ').combobox('select','all'); $('#jgCodeValueMZ').combobox('select','all');">重置</a>
            </form>
        </div>
        <table id="mzServiceDetail"></table>
    </div>
    <div id="shantouZYservice_window" class="easyui-window"
         style="width:1708px; height: 660px;padding: 0px; display: none;"
         data-options=" cache:false, collapsible:false,minimizable:false,maximizable:false,resizable:false,shadow:false,closed:true">
        <div style=" margin:8px; margin-left:20px; text-align: left;">
            <form id="zy_service_form">
                <span style="font-size: 15px;font-weight: 700px">区县:</span>
                <select id="qxCodeValueZY" class="easyui-combobox" style="width:200px;z-index: 99;">
                </select>
                <span style="font-size: 15px;font-weight: 700px">乡镇:</span><select id="xzCodeValueZY"
                                                                                   class="easyui-combobox"
                                                                                   style="width:200px;"></select>
                <span style="font-size: 15px;font-weight: 700px">机构:</span><select id="jgCodeValueZY"
                                                                                   class="easyui-combobox"
                                                                                   style="width:250px;"></select>
            <#--<span style="font-size: 15px;font-weight: 700px">日期:</span> <input  id="startDataZY" class="easyui-datetimebox" value="new Date().Format('yyyy-MM-dd');"  data-options="formatter:converDate,showSeconds: false"  style="width:200px">-->
            <#--<span style="font-size: 15px;font-weight: 700px">至:</span> <input  id="endDataZY" class="easyui-datetimebox"  value="new Date().Format('yyyy-MM-dd');" data-options="formatter:converDate,showSeconds: false"  style="width:200px">-->
                <a href="javascript:void(0);" class="easyui-linkbutton searchBt" iconCls="icon-search"
                   style=" margin-left: -5px;" onclick="zyServiceDetail()">查询</a>
                <a class="easyui-linkbutton resetBt" href="javascript:void(0)" iconCls="icon-reset"
                   onclick=" $('#qxCodeValueZY').combobox('select','all');  $('#xzCodeValueZY').combobox('select','all'); $('#jgCodeValueZY').combobox('select','all');">重置</a>
            </form>

        </div>
        <table id="zyServiceDetail"></table>
    </div>
</div>
</div>

</body>
</html>