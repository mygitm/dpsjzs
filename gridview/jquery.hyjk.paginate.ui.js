(function ($) {
    function paginate(ele, opt) {
        this.$element = ele;
        this.pageData = [];
        this.currentPage = 1;
        this.pageCount = 0;
        this.selectDates = [];
        this.autoHeight=false;
        this.AjaxQueue = new Array();
        this.map={};
        this.checkedDateBoolean = function (_date) {
            if (typeof(_date) != "undefined" && _date != "" && _date != null) {
                return true;
            }
            return false;
        },
            this.checkedDateString = function (_date) {
                if (typeof(_date) != "undefined" && _date != "" && _date != null) {
                    return _date;
                }
                return "";
            }
        this.mapElements = new Array();
        this.mapSize = function() {
            return this.mapElements.length;
        }
        this.mapPut = function(_key, _value) {
            this.mapElements .push( {
                key : _key,
                value : _value
            });
        }
        this.mapRemove = function(_key) {
            try {
                for (i = 0; i < this.mapElements.length; i++) {
                    if (this.mapElements [i].key == _key) {
                        this.mapElements.splice(i, 1);
                        return true;
                    }
                }
            } catch (e) {
                console.log(e)
            }
            return false;
        }
        this.mapGetValues= function() {
            return this.mapElements;

        }
        this.objectId = '';
        this.id = Math.random().toString(36).substr(3);
        this.defaults = {
            url: "", // 数据来源
            data: {}, //获取数据
            checkBox: false, // 选择框
            width: '100%',
            height: 100,
            params: {},
            subGrid: false,
            subData: [],
            singleton: false,//设置单选
            method: 'post',
            pagingType: 'full', //默认分页样式
            total: 0,
            pageSize: 10, // 在设置分页属性的时候初始化页面大小。
            onClick: function (rows, ele) {
            },
            onBeforeExpand: function (row, callBack) {
            },
            columns: [], // 列元素
            loadData: [],
            pagination: true //分页
        };
        this.defaultColumns = {
            field: '',
            title: '',
            width: 0,
            hidden: false,
            align: 'center',
            showTips: false,
            tipLength: 0,
            formatter: function (value, row) {
                return value
            }
        };
        this.options = $.extend({}, this.defaults, opt);
    }

    paginate.prototype.init = function () {
        these = this;
        this.objectId = $(this.$element).attr("id");
        $(this.$element).addClass('tablehover gridTableContent');
        this.gridView(1);
    }

    paginate.prototype.ajaxQueueAdd = function (fn) {
        this.AjaxQueue.push(fn);
    }

    paginate.prototype.exeRequestArray = function () {
        if (this.AjaxQueue.length > 0) {
            return this.AjaxQueue.shift();
        }
        return "";
    }

    paginate.prototype.initData = function () {
        if (this.checkedDateBoolean(this.options.data.total) && Number(this.options.data.total) >= 1) {
            this.options.loadData = this.options.data.rows;
            this.options.total = this.options.data.total;
        }
        this.pageData.splice(0, this.pageData.length);
        if (this.options.loadData.length >= 1) {
            for (var i in this.options.loadData) {
                var object = new Object();
                for (var j = 0; j < this.options.columns.length; j++) {
                    object[this.options.columns[j].field] = this.getDate(this.options.loadData[i], this.options.columns[j].field);
                }
                this.pageData[i] = object;
            }
        }
    }

    paginate.prototype.getSelections = function () {
        return this.selectDates;
    }

    paginate.prototype.formatterValue = function (_object) {
        return $.extend({}, this.defaultColumns, _object);
    }

    paginate.prototype.requestService = function () {
        if (this.checkedDateBoolean(this.options.url)) {
            this.toAjax(this.options.url, function (resule) {
                these.options.data = resule;
            });
        }
        this.initData();
    }

    paginate.prototype.toAjax = function (_url, callBack) {
        this.options.params['page'] = this.currentPage;
        this.options.params['rows'] = this.options.pageSize;
        var message = this.exeRequestArray();
        $.ajax({
            type: this.options.method, dataType: "json", async: false,
            cache: false,
            url: _url,
            data: this.options.params,
            beforeSend: function () {
                eval(message);
            }, success: function (result) {
                callBack(result);
            }
        });
    }

    paginate.prototype.pagination = function () {
        if (this.options.pagination) {
            var width = this.options.subGrid == true ? this.options.width + 52 : this.options.width+22;
            this.pageCount = Math.ceil(this.options.total / this.options.pageSize);
            if ($("#grid_footer".concat(this.objectId)).length <= 0) {
                $(this.$element).parent().parent().append('<div id="grid_footer' + this.objectId + '" ><table class="grid_footer_table" ><tr></tr></table></div>');
            }
            $(".grid_footer_table").attr("width", width);
            $("#grid_footer".concat(this.objectId)).find('table').find('tr').empty();
            $("#grid_footer".concat(this.objectId)).find('table').find('tr').append('<td class="dataTables_paginate paging_full" width="70%">' +
                '<ul class="pagination" style="margin-top: 5px;margin-bottom: 5px;margin-left: 35px;">' +
                '<li class="paginate_button first disabled" aria-controls="userGrid" tabindex="0" id="userGrid_first' + this.id + '"><a href="#">首页</a></li>' +
                '<li class="paginate_button previous disabled" aria-controls="userGrid" tabindex="0"  id="userGrid_previous' + this.id + '"><a href="#">上一页</a></li>' +
                '<li class="paginate_button next" aria-controls="userGrid" tabindex="0" id="userGrid_next' + this.id + '"><a href="#">下一页</a></li>' +
                '<li class="paginate_button last" aria-controls="userGrid" tabindex="0" id="userGrid_last' + this.id + '"><a href="#">末页</a></li>' +
                '<li class="gotoPage" style="margin-left: 10px;">跳转<input type="text" onkeyup = "value=value.replace(/[^\\d]/g,\'\')" id="textGotoPage' + this.id + '" style="width: 40px; height:35px; text-align: center; border:1px solid #ddd" title="回车确认" data-prev="1" value="' + this.currentPage + '"></li></ul></td>').append('<td width="30%"> <div class="dataTables_info" id="userGrid_info" role="alert" aria-live="polite" aria-relevant="all">显示 1 到 ' + this.options.pageSize + '项，共' + this.pageCount + '页</div></td>>');
            if (this.pageCount <= 1) {
                $("#userGrid_next" + this.id).addClass('disabled');
                $("#userGrid_last" + this.id).addClass('disabled');
            }
            if (this.pageCount > 1 && this.currentPage > 1 && this.currentPage < this.pageCount){
                $("#userGrid_first" + this.id).removeClass('disabled');
                $("#userGrid_previous" + this.id).removeClass('disabled');
                $("#userGrid_next" + this.id).removeClass('disabled');
                $("#userGrid_last" + this.id).removeClass('disabled');
            }
            if (this.pageCount == this.currentPage && this.pageCount > 1){
                $("#userGrid_first" + this.id).removeClass('disabled');
                $("#userGrid_previous" + this.id).removeClass('disabled');
                $("#userGrid_next" + this.id).addClass('disabled');
                $("#userGrid_last" + this.id).addClass('disabled');
            }
        }
    }

    paginate.prototype.getDate = function (_objectValues, field) {
        var value = ""
        $.each(_objectValues, function (key, val) {
            if (key == field) {
                value = _objectValues[key];
            }
        });
        return value;
    }

    paginate.prototype.gridView = function (_currentPage) {
        if (_currentPage != null && _currentPage != "") {
            this.currentPage = _currentPage;
        }
        var width = this.options.subGrid == true ? this.options.width + 30 : this.options.width;

        if ($("#grid_body".concat(this.objectId)).length <= 0){
            $("body").append('<div id="showTips" class="tip" style="position:absolute;left:0;top:0;display:none;z-index: 9999"></div>');
            $(this.$element).parent().append("<div id='grid_content" + this.objectId + "' style='position: relative;'><div id='content_loading" + this.objectId + "' style=\"position: absolute; top:36px;  background:rgba(35,35,35,0.1)\"><div   style=\" margin-top:220px;\" class=\"loader-inner ball-spin-fade-loader\"><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div></div></div></div></div>")
            $("#grid_content".concat(this.objectId)).append('<div id="grid_head' + this.objectId + '" style="padding-left: 1px;background-color:#DEEDF7; "> </div>');
            $("#grid_content".concat(this.objectId)).append('<div id="grid_body' + this.objectId + '" style="  overflow: auto;overflow-x:hidden; border:  1px solid #DEEDF7;" ></div>');
        }
        document.getElementById("content_loading".concat(this.objectId)).style.display = "";
        $("#content_loading".concat(this.objectId)).children().css("margin-left", Math.round((width / 2) - 50) + "px");
        $("#content_loading".concat(this.objectId)).css({"width":width + 22,"height":this.options.height+"px"});
        this.selectDates.splice(0, these.selectDates.length);
        $("#grid_head".concat(this.objectId)).empty();
        $("#grid_head".concat(this.objectId)).append('<table  id="head_' + this.objectId + '"><thead><tr></tr></thead></table>')
        $("#head_".concat(this.objectId)).addClass("gridTableHead");
        if (this.options.subGrid) {
            $("#head_".concat(this.objectId)).find('thead').find('tr').append("<td width='30'></td>");
        }
        $(this.$element).attr("width", width);
        $(this.$element).empty();
        $(this.$element).append("<tbody></tbody>");
        for (var h = 0; h < this.options.columns.length; h++){
            var _columnsObject = this.formatterValue(this.options.columns[h]);
            if (_columnsObject.hidden == false) {
                $("#head_".concat(this.objectId)).find('thead').find('tr').append("<td width='" + this.options.columns[h].width + "'>" + this.options.columns[h].title + "</td>");
            }
        }
        this.requestService();
        $("#grid_body".concat(this.objectId)).css({"width":width + 22,"height":this.options.height+"px"});
        $("#head_".concat(this.objectId)).attr("width", width + 20);
        $("#grid_head".concat(this.objectId)).css({"width": width + 20, "padding-left": "1px"});
        if (Math.round(this.pageData.length * 35) > this.options.height) {
            $("#head_".concat(this.objectId)).find('thead').find('tr').append("<td width='20'></td>");
        }
        $("#content_loading".concat(this.objectId)).children().css("margin-left", Math.round((width / 2) - 50) + "px");
        for (var i = 0; i < this.pageData.length; i++) {
            var html = "";
            if (this.options.subGrid) {
                html = "<td width='30' style='text-align: right;'><a id='" + i + "' class='expands gridSub_icon_1' style='text-decoration:none;  cursor: pointer' >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</a></td>";
            }
            for (var j = 0; j < this.options.columns.length; j++) {
                var columnsObject = this.formatterValue(this.options.columns[j]);
                var tip = "";
                if (columnsObject.showTips && this.checkedDateBoolean(this.pageData[i][this.options.columns[j].field]) && this.pageData[i][this.options.columns[j].field].length > columnsObject.tipLength) {
                    tip = tip.concat(" tips='").concat(this.pageData[i][this.options.columns[j].field]).concat("' class='lsddShowTips'");
                }
                if (i == 0) {
                    if (columnsObject.hidden == false) {
                        html += "<td align='" + columnsObject.align + "' width='" + this.options.columns[j].width + "'" + tip + ">" + this.formatterValue(this.options.columns[j]).formatter(this.checkedDateString(this.pageData[i][this.options.columns[j].field]), this.pageData[i]) + "</td>";
                    } else {
                        html += "<td style='display: none'>" + this.formatterValue(this.options.columns[j]).formatter(this.checkedDateString(this.pageData[i][this.options.columns[j].field]), this.pageData[i]) + "</td>";
                    }
                } else {
                    if (columnsObject.hidden == true) {
                        html += "<td style='display: none'>" + this.formatterValue(this.options.columns[j]).formatter(this.checkedDateString(this.pageData[i][this.options.columns[j].field]), this.pageData[i]) + "</td>";
                    } else {
                        html += "<td align='" + columnsObject.align + "'" + tip + ">" + this.formatterValue(this.options.columns[j]).formatter(this.checkedDateString(this.pageData[i][this.options.columns[j].field]), this.pageData[i]) + "</td>";
                    }
                }
            }
            if (this.options.subGrid) {
                $(this.$element).find('tbody').append("<tr id='" + "chidens_val".concat(this.objectId).concat(i) + "' >" + html + "</tr>");
                $(this.$element).find('tbody').append("<tr id='" + "chidens_".concat(this.objectId).concat(i) + "' class='displaySub' ><td></td><td style='padding: 0px;' colspan='" + this.options.columns.length + "'><div id='" + "chidens_div_".concat(this.objectId).concat(i) + "'  style='margin: 0px;padding: 0px; width: 100%;display: none;'></div></td></tr>");
                $("#chidens_".concat(these.objectId).concat(i)).children().eq(1).append("<div id='" + "chidens_div_loadin".concat(these.objectId).concat(i) + "' style='text-align: center;'><div id='' style='width:30px;height:30px;margin-left:650px;'class='loader-inner ball-clip-rotate-multiple'><div></div><div></div></div></div>");
            } else {
                $(this.$element).find('tbody').append("<tr>" + html + "</tr>");
            }
        }

        if (Math.round(this.pageData.length * 35) < this.options.height){
            var theadLastTd=$("#head_".concat(this.objectId)).find('thead').find('tr').find("td:last").attr("width");
            $("#head_".concat(this.objectId)).find('thead').find('tr').find("td:last").attr("width",Number(theadLastTd)+20);
            var tbodyLastTd= $(this.$element).find('tbody').find('tr').eq(0).find("td:last").attr("width");
            $(this.$element).find('tbody').find('tr').eq(0).find("td:last").attr("width",Number(tbodyLastTd)+20);
        }

        $("#grid_body".concat(this.objectId)).append($(this.$element));
        this.pagination();
        this.initClick();
        document.getElementById("content_loading".concat(this.objectId)).style.display = "none";
    }

    paginate.prototype.initClick = function () {
        if (this.options.pagination == true) {
            $("#userGrid_next" + this.id).on('click', function () {
                if (!$(this).hasClass('disabled')) {
                    these.pageNext();
                }
            });
            $("#userGrid_previous" + this.id).on('click', function () {
                if (!$(this).hasClass('disabled')) {
                    these.pagePrevious();
                }
            });
            $("#userGrid_first" + this.id).on('click', function () {
                if (!$(this).hasClass('disabled')) {
                    these.pageGridView(1);
                }
            });
            $("#userGrid_last" + this.id).on('click', function () {
                if (!$(this).hasClass('disabled')) {
                    these.pageGridView(these.pageCount);
                }
            });
            $("#textGotoPage" + this.id).bind('keydown', function (event) {
                var event = window.event || arguments.callee.caller.arguments[0];
                if (event.keyCode == 13) {
                    var pageValue = $(this).val();
                    pageValue = pageValue > these.pageCount ? these.pageCount : pageValue <= 0 ? 1 : pageValue;
                    these.pageGridView(pageValue);
                }
            });
        }
        $(this.$element).find('tbody').on('click', 'tr', function () {
            if ($(this).hasClass('selected')) {
                $(this).removeClass('selected');
                these.removeSelectValues($(this));
            } else {
                $(this).removeClass('selected');
                $(this).addClass('selected');
                if (these.options.singleton == true) {
                    $(this).siblings().removeClass('selected');
                    these.selectDates.splice(0, these.selectDates.length);
                }
                these.addSelectDates($(this));
                these.options.onClick(these.getSelectValues(), these);
            }

        });
        $(".lsddShowTips").mousemove(function (e) {
            $("#showTips").text($(this).attr("tips")).css({
                "display": "",
                "top": these.eventXY(e).y + 5 + "px",
                "left": these.eventXY(e).x + 10 + "px"
            });
        });
        $(".lsddShowTips").mouseout(function () {
            $("#showTips").css("display", "none");
        });
        $(".expands").click(function () {
            var _id = $(this).attr("id");
            $("#chidens_".concat(these.objectId).concat(_id)).slideToggle();
            if ($(this).hasClass('gridSub_icon_1')) {
                $("#chidens_div_".concat(these.objectId).concat(_id)).empty();
                $("#chidens_div_".concat(these.objectId).concat(_id)).append("<table class='table-hover gridTableSub' cellpadding='0' cellspacing='0' ><tbody></tbody></table>");
                $("#chidens_div_loadin".concat(these.objectId).concat(_id)).removeClass('displaySub');
                these.options.onBeforeExpand(these.getSelectValues($("#chidens_val".concat(these.objectId).concat(_id))), function (data) {
                    setTimeout(function () {
                        if (data.length > 0) {
                            $(".gridTableSub").attr("width", these.options.width);
                            for (var i = 0; i < data.length; i++) {
                                var _tr = "";
                                for (var j = 0; j < these.options.columns.length; j++) {
                                    var columnsObject = these.formatterValue(these.options.columns[j]);
                                    var _tips = "";
                                    if (columnsObject.showTips && these.checkedDateBoolean(data[i][these.options.columns[j].field]) && data[i][these.options.columns[j].field].length > columnsObject.tipLength) {
                                        _tips = _tips.concat(" tips='").concat(data[i][these.options.columns[j].field]).concat("' onmousemove='tip.start(this)'");
                                    }
                                    if (columnsObject.hidden == false){
                                        _tr += "<td align='" + columnsObject.align + "' width='" + these.options.columns[j].width + "'" + _tips + ">" + these.formatterValue(these.options.columns[j]).formatter(these.checkedDateString(data[i][these.options.columns[j].field]), data[i]) + "</td>";
                                    } else {
                                        _tr += "<td style='display: none'></td>";
                                    }
                                }
                                $("#chidens_div_".concat(these.objectId).concat(_id)).find('table').find('tbody').append("<tr>" + _tr + "</tr>");
                            }
                            var subTableLastTd= $("#chidens_div_".concat(these.objectId).concat(_id)).find("table>tbody>tr").eq(0).find("td:last").attr("width");
                            $("#chidens_div_".concat(these.objectId).concat(_id)).find("table>tbody>tr").eq(0).find("td:last").attr("width",Number(subTableLastTd)+20);
                        }
                        these.mapPut("chidens_".concat(these.objectId).concat(_id),data.length>0?data.length*35:35);
                        var tableHeight=0;
                        $.each(these.mapGetValues(),function (key,obj) {
                            tableHeight+=obj.value;
                        })
                        if(Number(tableHeight+(these.pageData.length * 35))>these.options.height&&!these.autoHeight&&(these.pageData.length * 35)<these.options.height){
                            var theadLastTd=$("#head_".concat(these.objectId)).find('thead').find('tr').find("td:last").attr("width");
                            $("#head_".concat(these.objectId)).find('thead').find('tr').find("td:last").attr("width",Number(theadLastTd)-20);
                            var tbodyLastTd= $(these.$element).find('tbody').find('tr').eq(0).find("td:last").attr("width");
                            $(these.$element).find('tbody').find('tr').eq(0).find("td:last").attr("width",Number(tbodyLastTd)-20);
                            $("#head_".concat(these.objectId)).find('thead').find('tr').append("<td width='20'></td>");
                            these.autoHeight=true;
                        }
                        $("#chidens_div_loadin".concat(these.objectId).concat(_id)).addClass('displaySub');
                    }, 500);
                });
                $(this).removeClass('gridSub_icon_1');
                $(this).addClass('gridSub_icon_2');
            } else {
                these.mapRemove("chidens_".concat(these.objectId).concat(_id));
                var tableHeight=0;
                if(these.mapSize()>0){
                    $.each(these.mapGetValues(),function (key,obj){
                        tableHeight+=obj.value;
                    })
                }
                if(Number(tableHeight+(these.pageData.length * 35))<these.options.height&&these.autoHeight){
                    $("#head_".concat(these.objectId)).find('thead').find('tr').find("td:last").remove();
                    var theadLastTd=$("#head_".concat(these.objectId)).find('thead').find('tr').find("td:last").attr("width");
                    $("#head_".concat(these.objectId)).find('thead').find('tr').find("td:last").attr("width",Number(theadLastTd)+20);
                    var tbodyLastTd= $(these.$element).find('tbody').find('tr').eq(0).find("td:last").attr("width");
                    $(these.$element).find('tbody').find('tr').eq(0).find("td:last").attr("width",Number(tbodyLastTd)+20);
                    these.autoHeight=false;
                }
                $(this).removeClass('gridSub_icon_2');
                $(this).addClass('gridSub_icon_1');
            }
            $("#chidens_div_".concat(these.objectId).concat(_id)).slideToggle();
        });
        $('.gridTableContent tbody tr').hover(function (e) {
            $(this).siblings().css({"background": ""});
            $(this).css({"background": "#E4F1FB"});
        }, function () {
            $(this).siblings().css({"background": ""});
        });

    }

    paginate.prototype.pageGridView = function (rows) {
        document.getElementById("content_loading".concat(these.objectId)).style.display = "";
        setTimeout(function () {
            these.gridView(rows);
        }, 100);
    }
    paginate.prototype.pageNext = function () {
        if (this.currentPage < this.pageCount) {
            this.currentPage += 1;
        }
        this.pageGridView(this.currentPage);

    }

    paginate.prototype.pagePrevious = function () {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
        }
        this.pageGridView(this.currentPage);
    }

    paginate.prototype.pageFirst = function () {
        this.gridView(1);
    }

    paginate.prototype.pageLast = function () {
        these.gridView(this.pageCount);
    }

    paginate.prototype.addSelectDates = function ($object) {
        var i = this.selectDates.length;
        this.selectDates[i] = this.getSelectValues($object);
    }
    paginate.prototype.getSelectValues = function ($object) {
        var itemValue = new Object();
        try {
            var i1 = this.options.subGrid == true ? 1 : 0;
            for (var i = i1; i < $object.children().length; i++) {
                itemValue[this.options.columns[i - i1].field] = $object.children().eq(i).text();
            }
        } catch (e) {
            console.log("获取数据异常" + e);
        }
        return itemValue;

    }
    paginate.prototype.removeSelectValues = function ($object, removeNum) {
        this.selectDates.splice($.inArray(this.getSelectValues($object), this.selectDates), 1);
    }

    paginate.prototype.eventXY = function (e) {
        var e = e || window.event;
        return {
            x: e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft,
            y: e.clientY + document.body.scrollTop + document.documentElement.scrollTop
        };
    }

    $.fn.gridView = function (options) {
        return new paginate(this, options).init();
    };
})(jQuery);