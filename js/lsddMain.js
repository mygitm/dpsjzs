function lsddCharts(){
    this. mapCityDate=[];
    this.geoCoordCity={};
    this.geoCoordMap={};
    this.mapColors = ['#71b66d','#D7CEFD','#FF00FF','#6A5ACD','#33b9a8','#a98671','#2a8dca'];
    this.initYljgsrBar=null;
    this.initJdqybar=null;
    this.initServiceZyBarOnClick=false;
    this.initServiceZyBar=null;
    this.initServiceMzBar=null;
    this.diseaseNephogramsOnmouse=false;
    this.initServiceMzBarOnClick=false;
    this.initMapOnClick=false;
    this.timeTotalsValue=null;
    this.org_unitData = new Array();
    this.orgData =new Array();
    this.units =new Array();
    this.unitData =new Array();
    this.orgDataChange=[];
    this.unitDataChange=[];
    this.orgDataChangeTwo=[];
    this.orgDataChangeZY=[];
    this.unitDataChangeZY=[];
    this.orgDataChangeTwoZY=[];
    this.initDiseaseNephograms=null;
    this.elements = new Array();
    this.clear = function() {
        this.elements = new Array();
    }
    this.size = function() {
        return this.elements.length;
    }
    this.put = function(_key, _value) {
        this.elements.push( {
            key : _key,
            value : _value
        });
    }
    this.get = function(_key) {
        try {
            for (var i = 0; i < this.elements.length; i++) {
                if (this.elements[i].key == _key) {
                    return this.elements[i].value;
                }
            }
        } catch (e) {
            return null;
        }
    }
    this.getValues= function() {
        return this.elements;

    }
    this.zyywBar_option={
        title: {x:'center',
            textStyle:{
                color:'#FFFFFF'
            }
        },
        color:['#22FF7A', '#ff6600','#22A7FF','#D322FF'],
        tooltip: {trigger: 'axis', axisPointer: {type: 'cross', crossStyle: {color: '#999'}}
        },
        legend: {type: 'scroll', bottom: 8,
            textStyle:{color:'#FFFFFF'}
        },
        xAxis: [
            {
                type: 'category',data:['00:00','01:00','02:00','03:00','04:00','05:00','06:00','07:00','08:00','09:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00','19:00','20:00','21:00','22:00','23:00'],
                axisPointer: {type: 'shadow', label: {backgroundColor: '#666666'}},
                axisLine: {lineStyle: {color: '#FFFFFF'}
                }
            }
        ],
        yAxis:[
            {type: 'value', name: '',
                axisLine: {lineStyle: {color: '#FFFFFF'}
                },axisPointer: {label: {backgroundColor: '#666666'}}
            },
            {
                type: 'value', name: '',// interval: 10,
                axisLine: {lineStyle: {color: '#FFFFFF'}
                },axisPointer: {label: {backgroundColor: '#666666'}}
            }
        ],series: [
            {
                name:'', type:'bar'
            },
            {
                name:'', type:'bar'
            },
            {
                name:'', type:'line', yAxisIndex: 1
            }
            ,
            {
                name:'', type:'line', yAxisIndex: 1
            }
        ]
    };

    this.jdqybar_option={
        title: {
            x:'center',
            textStyle:{
                color:'#FFFFFF'
            }
        },
        color: ['#ff6633','#6699cc'],
        tooltip: {trigger: 'axis',
            axisPointer: {
                type: 'cross',
                crossStyle: {
                    color: '#999'
                }
            }
        },legend: {type: 'scroll', bottom: 8, textStyle:{color:'#FFFFFF'}
        },
        xAxis: [{
            type: 'category',
            axisPointer: {
                type: 'shadow',label: {backgroundColor: '#666666'}
            },
            axisLine: {lineStyle: {color: '#FFFFFF'}}
        }
        ],
        yAxis: [
            {
                type: 'value',
                min: 0,
                axisLine: {lineStyle: {color: '#FFFFFF'}},
                axisPointer: {label: {backgroundColor: '#666666'}}
            }
        ],series: [
            {
                type:'bar'
            },
            {
                type:'bar',
            }
        ]
    };

    this.yljgsrbar_option ={
        title: {x:'center', textStyle:{color:'#FFFFFF'}},
        tooltip : {
            trigger: 'item',
            formatter: "{a} <br/>{b} : ¥{c} ({d}%)"
        },
        calculable : true,
        series : [
            {
                name:'',label: {
                    normal: {show: true, formatter: '{b} : ¥{c} ({d}%)'
                    },
                    emphasis: {
                        show: true
                    }
                },
                type:'pie', radius : [10, 95], center : ['50%', '50%'], roseType : 'area'
            }
        ]
    };
    this.jbytCharts_option= {
        title: {
            x:'center',
            textStyle:{color:'#FFFFFF'}
        },
        tooltip: {show: true},
        series: [{
            type : 'wordCloud',
            width:"98%",
            height:"98%",
            drawOutOfBound: true,
            textRotation : [10, 45, 90, -45],
            textPadding: 0,
            sizeRange: [10, 25],
            textStyle: {
                normal: {
                    color: function() {
                        return 'rgb(' + [Math.round(Math.random() * 160), Math.round(Math.random() * 120), Math.round(Math.random() * 130)].join(',') + ')';
                    }
                }, emphasis: {shadowBlur: 5, shadowColor: '#333'}
            }
        }]
    };

    this.mapOption={
        tooltip: {
            show:true,
            formatter: function(params){


                if(params.seriesIndex==1){
                    return  params.data.orgname;
                }
                if(params.data.value){
                    return  setTitleDate.orgname;
                }
            }
        },
        layoutSize: '100%',
      /*  geo: {
            map: '汕头', show: false
        },*/
        series: [
            {
                type: 'map',
           //     map: '汕头',
                geoIndex: 1,
                showLegendSymbol: true,
                aspectScale: 1.0,
                radius : [ 30, 100 ],
                label: {
                    normal: {
                        show: true,
                        color: '#fff',
                        formatter: function(params){
                            return '{name|' + params.name + '}';
                        },
                        rich: {
                            name: {
                                color: '#ffffff',
                                fontSize: 13
                            },
                            value: {
                                color: '#ffffff',
                                fontSize: 13
                            }
                        }
                    }
                },
                itemStyle: {
                    normal: {
                        borderColor: '#389BB7',
                        areaColor: '#4CD2E1',
                    },emphasis: {
                        areaColor: '#0B62C3'
                    }
                },
                animation: false
            },
            {
                type: 'scatter',
                coordinateSystem: 'geo',
                symbolSize: function () {
                    return 5;
                },
                label: {
                    normal: {
                        formatter: '',
                        position: 'right',
                        show: false
                    },
                    emphasis: {
                        show: true
                    }
                },
                itemStyle: {
                    normal: {
                        color: '#ddb926'
                    }
                }
            },
            {
                type: 'effectScatter',
                coordinateSystem: 'geo',
                symbolSize: function () {
                    return 11;
                },
                showEffectOn: 'render',
                rippleEffect: {
                    brushType: 'stroke'
                },
                hoverAnimation: true,
                label: {
                    normal: {
                        formatter: '',
                        position: 'right',
                        show: false
                    }
                },
                itemStyle: {
                    normal: {
                        color: '#f4e925',
                        shadowBlur: 10,
                        shadowColor: '#333'
                    }
                },
                zlevel: 1
            }
        ]
    }


}

lsddCharts.prototype.ajaxCharts=function(_url,callBack){
    $.ajax({
        type: "POST", dataType:"json", contentType:"application/json",  async: false,
        cache: false,
        url:_url,
        success: function(result){
            callBack(result);
        }
    });
}

lsddCharts.prototype.chartsInit=function(_document){
    return echarts.init(_document);
}


//全市当日疾病云图
lsddCharts.prototype.showDiseaseNephograms=function(_objecdtChart,_unitId,_grade){
    var data;
    this.ajaxCharts('lsddCharts/queryDiseaseNephograms?unitId='+_unitId+"&grade="+_grade,function(result){
        data=result;
    });
    try {
        if (typeof(data) != "undefined"){
            /*   if( this.initDiseaseNephograms!=null) {
                   this.initDiseaseNephograms.dispose();
               }*/
            this.initDiseaseNephograms = _objecdtChart;
            this.jbytCharts_option.series[0].data=data;
            this.initDiseaseNephograms.setOption(this.jbytCharts_option);

        }
    } catch(e){
        console.log("住院业务分时段统计图"+e);
    }
    return  this.initDiseaseNephograms;

}



//门诊业务分时段统计图
lsddCharts.prototype.showServiceMzBar=function(_objecdtChart,_unitId){
    this.initServiceMzBar=_objecdtChart;
    var data;
    this.ajaxCharts('lsddCharts/queryOutpatientByTimesolt?unitId='+_unitId,function(result){
        data=result;
    });
    try {
        this.zyywBar_option.legend.data=['当日门诊(元)','昨日门诊(元)','当日门诊均次费用(元)','昨日门诊均次费用(元)'];
        this.zyywBar_option.series[0].name='当日门诊(元)';
        this.zyywBar_option.series[0].data=data[0];
        this.zyywBar_option.series[1].name='昨日门诊(元)';
        this.zyywBar_option.series[1].data=data[1];
        this.zyywBar_option.series[2].name='当日门诊均次费用(元)';
        this.zyywBar_option.series[2].data=data[2];
        this.zyywBar_option.series[3].name='昨日门诊均次费用(元)';
        this.zyywBar_option.series[3].data=data[3];
        this.formatLineBaryAxis( this.zyywBar_option,data[4]);
        this.initServiceMzBar.setOption(this.zyywBar_option);
        return   this.initServiceMzBar;
    } catch (e) {
        console.log("门诊业务分时段统计图出错："+e);
    }

}


//住院业务分时段统计图"
lsddCharts.prototype.showServiceZyBar=function(_objecdtChart,_unitId){
    this.initServiceZyBar=_objecdtChart;
    var data;
    this.ajaxCharts('lsddCharts/queryHospitalizationByTimesolt?unitId='+_unitId,function(result){
        data=result;
    });
    try{
        this.zyywBar_option.legend.data=['当日住院结算(元)','昨日住院结算(元)','当日住院均次费用(元)','昨日住院均次费用(元)'];
        this.zyywBar_option.series[0].name='当日住院结算(元)';
        this.zyywBar_option.series[0].data=data[0];
        this.zyywBar_option.series[1].name='昨日住院结算(元)';
        this.zyywBar_option.series[1].data=data[1];
        this.zyywBar_option.series[2].name='当日住院均次费用(元)';
        this.zyywBar_option.series[2].data=data[2];
        this.zyywBar_option.series[3].name='昨日住院均次费用(元)';
        this.zyywBar_option.series[3].data=data[3];
        this.formatLineBaryAxis( this.zyywBar_option,data[4]);
        this.initServiceZyBar.setOption(this.zyywBar_option);
         return  this.initServiceZyBar;

    } catch (e) {
        console.log("住院业务分时段统计图"+e);
    }
}


lsddCharts.prototype.formatLineBaryAxis=function(_option,_lineOrBarArry){
    var  maxBarValue=Number(_lineOrBarArry[0])>Number(_lineOrBarArry[1])?Number(_lineOrBarArry[0]):Number(_lineOrBarArry[1]);
    if(maxBarValue>1200) {
        var maxOne = (Math.round(maxBarValue) - (Math.round(maxBarValue) % 5));
        var yAxisMaxOne = maxOne + (maxOne / 5);
        _option.yAxis[0].max = yAxisMaxOne;
        _option.yAxis[0].interval = Math.round(maxOne/ 5);
    }else{
        _option.yAxis[0].max = 1200;
        _option.yAxis[0].interval =200;
    }
    var  maxLineValue=Number(_lineOrBarArry[2])>Number(_lineOrBarArry[3])?Number(_lineOrBarArry[2]):Number(_lineOrBarArry[3]);
    if(maxLineValue>120) {
        var maxTwo = (Math.round(maxLineValue) - (Math.round(maxLineValue) % 5));
        var yAxisMaxTow = maxTwo + (maxTwo / 5);
        _option.yAxis[1].max = yAxisMaxTow;
        _option.yAxis[1].interval = Math.round(maxTwo / 5);
    }else{
        _option.yAxis[1].max =120;
        _option.yAxis[1].interval =20;
    }
}

//全市当日医疗机构收入
lsddCharts.prototype.showYljgsrBar=function(_objecdtChart,_unitId){
    this.initYljgsrBar=_objecdtChart;
    var data;
    this.ajaxCharts('lsddCharts/queryFeeType?unitId='+_unitId,function(result){
        data=result;
    });
    try{
        this.yljgsrbar_option.series[0].name='医疗机构費用';
        this.yljgsrbar_option.series[0].data=[{value:data[0].FEE, name:data[0].TYPE_NAME,label:{color:'#FFFFFF'}}, {value:data[1].FEE, name:data[1].TYPE_NAME,label:{color:'#FFFFFF'}},
            {value:data[2].FEE, name:data[2].TYPE_NAME,label:{color:'#FFFFFF'}}, {value:data[3].FEE, name:data[3].TYPE_NAME,label:{color:'#FFFFFF'}}, {value:data[4].FEE, name:data[4].TYPE_NAME,label:{color:'#FFFFFF'}},
            {value:data[5].FEE, name:data[5].TYPE_NAME,label:{color:'#FFFFFF'}}, {value:data[6].FEE, name:data[6].TYPE_NAME,label:{color:'#FFFFFF'}}, {value:data[7].FEE, name:data[7].TYPE_NAME,label:{color:'#FFFFFF'}},
            {value:data[8].FEE, name:data[8].TYPE_NAME,label:{color:'#FFFFFF'}}, {value:data[9].FEE, name:data[9].TYPE_NAME,label:{color:'#FFFFFF'}}, {value:data[10].FEE, name:data[10].TYPE_NAME,label:{color:'#FFFFFF'}},
            {value:data[11].FEE, name:data[11].TYPE_NAME,label:{color:'#FFFFFF'}}, {value:data[12].FEE, name:data[12].TYPE_NAME,label:{color:'#FFFFFF'}}, {value:data[13].FEE, name:data[13].TYPE_NAME,label:{color:'#FFFFFF'}}];
        this.initYljgsrBar.setOption(this.yljgsrbar_option);
    } catch (e) {
        console.log("全市当日医疗机构收入"+e);
    }
}



//建档率与签约率
lsddCharts.prototype.showJdqybar=function(_objecdtChart,_unitId){
    this.initJdqybar=_objecdtChart;
    var data;
    this.ajaxCharts('lsddCharts/queryFilingAndContract?unitId='+_unitId,function(result){
        data=result;
    });
    var jkl_qyl_name=[];
    var jdl=[];
    var qyl=[];
    var maxNumber=0;
     if(typeof data!="undefined"&&data.length>=1){
          $.each(data,function (key,value) {
             if(!value.hasOwnProperty('maxNumber')){
                  jkl_qyl_name.push(value.administrativeName);
                  jdl.push(value.archives);
                  qyl.push(value.signing);
             }else{
                 maxNumber=value.maxNumber;
             }
          })
     }
    try{
        this.jdqybar_option.legend.data=['建档率','签约率'];
        this.jdqybar_option.xAxis[0].data=jkl_qyl_name;
        this.jdqybar_option.series[0].name='建档率';
        this.jdqybar_option.series[0].data=jdl;
        this.jdqybar_option.series[1].name='签约率';
        this.jdqybar_option.series[1].data=qyl;
        var  maxBarValue=Number(maxNumber);
        if(maxBarValue>100) {
            var maxOne = Math.round(maxBarValue) - (Math.round(maxBarValue) % 4);
            var yAxisMaxOne = maxOne + (maxOne / 4);
            this.jdqybar_option.yAxis[0].max = yAxisMaxOne;
            this.jdqybar_option.yAxis[0].interval = Math.round(maxOne / 4);
        }else{
            this.jdqybar_option.yAxis[0].max = 100;
            this.jdqybar_option.yAxis[0].interval =20;
        }
        this.initJdqybar.setOption(this.jdqybar_option);
    } catch (e) {
        console.log("'建档率与签约率报表报错"+e);
    }
}

//根据门诊/住院状态，确定是否跳转健康档案浏览器
lsddCharts.prototype.jumpToHrbs=function(value,row){
    if(row.status === "1"){
        return "<a href='javascript:openHrbc(\"" + row.idnum + "\")' style='color: #00AFFF;cursor:pointer;' >" + value + "</a>";
    }else{
        return "<a href='javascript:openHrbc(\"" + row.idnum + "\")' style='color: #00AFFF;cursor:pointer;' >" + "" + "</a>";
    }
}


