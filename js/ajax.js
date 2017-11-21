// Created by jjp 2017.11.21
// 调用例子
// ajax({     
//   url: 'test.php',   // 请求地址 
//   type: 'POST',   // 请求类型，默认"GET"，还可以是"POST" 
//   data: {'b': '异步请求'},   // 传输数据 
//   success: function(res){   // 请求成功的回调函数 
//     console.log(JSON.parse(res));     
//   },  
//   error: function(error) {}   // 请求失败的回调函数  
// });  
// 
// ajax({ 
//   url: 'test.php',    // 请求地址 
//   jsonp: 'jsonpCallback',  // 采用jsonp请求，且回调函数名为"jsonpCallbak"，可以设置为合法的字符串  
//   data: {'b': '异步请求'},   // 传输数据
//   success:function(res){   // 请求成功的回调函数 
//     console.log(res);     
//   },  
//   error: function(error) {}   // 请求失败的回调函数  
// });  

function ajax(params) {     
  params = params || {};     
  params.data = params.data || {};     
  // 判断是ajax请求还是jsonp请求  
  var json = params.jsonp ? jsonp(params) : json(params);     
  // ajax请求     
  function json(params) {     
    //  请求方式，默认是GET  
    params.type = (params.type || 'GET').toUpperCase();   
    // 避免有特殊字符，必须格式化传输数据    
    params.data = formatParams(params.data);     
    var xhr = null;  
    // 实例化XMLHttpRequest对象     
    if(window.XMLHttpRequest) {     
      xhr = new XMLHttpRequest();     
    } else {     
      // IE6及其以下版本     
      xhr = new ActiveXObjcet('Microsoft.XMLHTTP');     
    };   
  
    // 监听事件，只要 readyState 的值变化，就会调用 readystatechange 事件   
    xhr.onreadystatechange = function() {    
      //  readyState属性表示请求/响应过程的当前活动阶段，4为完成，已经接收到全部响应数据  
      if(xhr.readyState == 4) {     
        var status = xhr.status;    
        //  status：响应的HTTP状态码，以2开头的都是成功  
        if(status >= 200 && status < 300) {     
          var response = '';   
          // 判断接受数据的内容类型    
          var type = xhr.getResponseHeader('Content-type');     
          if(type.indexOf('xml') !== -1 && xhr.responseXML) {     
            response = xhr.responseXML; //Document对象响应     
          } else if(type === 'application/json') {     
            response = JSON.parse(xhr.responseText); //JSON响应     
          } else {     
            response = xhr.responseText; //字符串响应     
          };    
          // 成功回调函数   
          params.success && params.success(response);     
       } else {     
          params.error && params.error(status);     
       }     
      };     
    };    
 
    // 连接和传输数据     
    if(params.type == 'GET') {  
      // 三个参数：请求方式、请求地址(get方式时，传输数据是加在地址后的)、是否异步请求(同步请求的情况极少)；  
      xhr.open(params.type, params.url + '?' + params.data, true);     
      xhr.send(null);     
    } else {     
      xhr.open(params.type, params.url, true);     
      //必须，设置提交时的内容类型     
      xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');   
      // 传输数据    
      xhr.send(params.data);     
    }     
  }    
   // jsonp请求     
  function jsonp(params) {     
    //创建script标签并加入到页面中     
    var callbackName = params.jsonp;     
    var head = document.getElementsByTagName('head')[0];     
    // 设置传递给后台的回调参数名     
    params.data['callback'] = callbackName;     
    var data = formatParams(params.data);     
    var script = document.createElement('script');     
    head.appendChild(script);      
  
    //创建jsonp回调函数     
    window[callbackName] = function(json) {     
      head.removeChild(script);     
      clearTimeout(script.timer);     
      window[callbackName] = null;     
      params.success && params.success(json);     
    };      
  
    //发送请求     
    script.src = params.url + '?' + data;    
    //为了得知此次请求是否成功，设置超时处理     
    if(params.time) {     
     script.timer = setTimeout(function() {     
       window[callbackName] = null;     
       head.removeChild(script);     
       params.error && params.error({     
         message: '超时'     
       });     
     }, time);     
    }     
  };     
  
  //格式化参数     
  function formatParams(data) {     
    var arr = [];     
    for(var name in data) {   
      //   encodeURIComponent() ：用于对 URI 中的某一部分进行编码  
      arr.push(encodeURIComponent(name) + '=' + encodeURIComponent(data[name]));     
    };     
    // 添加一个随机数参数，防止缓存     
    arr.push('v=' + random());     
    return arr.join('&');     
  }  
  
  // 获取随机数     
  function random() {     
    return Math.floor(Math.random() * 10000 + 500);     
  }  
}  