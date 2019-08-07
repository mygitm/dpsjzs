var tip={$:function(ele){
        if(typeof(ele)=="object")
            return ele;
        else if(typeof(ele)=="string"||typeof(ele)=="number")
            return document.getElementById(ele.toString());
        return null;
    },
    mouseXY:function(e){
        var e = e||window.event;
        return{x:e.clientX+document.body.scrollLeft+document.documentElement.scrollLeft,
            y:e.clientY+document.body.scrollTop+document.documentElement.scrollTop};
    },
    start:function(obj){
        var self = this;
        var t = self.$("showTips");
        var tipsValue=obj.getAttribute("tips");
        if(tipsValue!="null"&&tipsValue!=""){
            obj.onmousemove = function (e) {
                var mouse = self.mouseXY(e);
                t.style.left = mouse.x + 10 + 'px';
                t.style.top = mouse.y + 5 + 'px';
                t.innerHTML =tipsValue;
                t.style.display = '';
            };
            obj.onmouseout = function () {
                t.style.display = 'none';
            };
        }
    }
}