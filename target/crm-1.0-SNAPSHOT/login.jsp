<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
	// request.getScheme() 得到的结果是：http
	// request.getServerName() 得到的结果是：localhost
	// request.getServerPort() 得到的结果是：8080
	// request.getContextPath() 得到的结果是：/crm

	String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
/*
	上面这条语句得到的结果是：basePath=http://localhost:8080/crm/
*/
%>
<html>

<head>
	<!--
		加上这个base标签后，后面需要写到路径时，可以直接写资源名称，其会自动加上：basePath=http://localhost:8080/crm/
		例如：以前写超链接时：<a href="/crm/settings/user/save">
		加上这个base标签后，可写为：<a href="settings/user/save"> ，其会自动加上 http://localhost:8080/crm/ 的内容
		即都是以绝对路径的形式访问服务器资源
	-->
	<base href="<%=basePath%>">
	<meta charset="UTF-8">
	<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
	<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
	<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>\

	<script type="text/javascript">
		$(function () {

			// 以下这个if判断是让登录窗口永远置于顶级窗口
			if(window.top !== window.self){
				window.top.location = window.self.location;
			}
			
			// 当页面加载完毕后，先清空用户名文本框与密码文本框中的内容
			$("#loginAct").val("");
			$("#loginPwd").val("");
			
			// 当页面加载完毕后，用户名文本框自动获得焦点
			$("#loginAct").focus();

			// 为按钮绑定鼠标单击事件，进行登录验证
			$("#submitBtn").click(function () {
				loginVerify();
			});

			// 为页面绑定键盘捕捉事件，使得用户按下回车后，可直接登录
			$(window).keydown(function (event) {
				if(event.keyCode === 13){
					loginVerify();
				}
			});
		});

		// 登录验证函数
		// 注意：自定义的function一定要放在$(function(){})的外面
		function loginVerify() {

			// 获取用户名和密码，需要去掉内容前后的空白格，推荐使用$.trim(值)
			var loginAct = $.trim($("#loginAct").val()); // 也可以使用这种方式获取：$("#loginAct").val().trim()
			var loginPwd = $.trim($("#loginPwd").val());

			// 1. 判断用户名和密码是否为空
			if(loginAct === "" || loginPwd === ""){
				// 程序能够执行到此处说明账号或密码至少有一个为空
				$("#errorMsg").html("用户名和密码不能为空");
				// 终止该方法
				return;
			}

			// 程序能够执行到此处说明账号和密码不为空
			// 2. 使用ajax，后台连接数据库，验证数据库中是否有该条记录
			$.ajax({
				url:"settings/user/loginVerification.do", // 注意：不能以"/"开头
				data:{"loginAct":loginAct, "loginPwd":loginPwd},
				type:"post",
				dataType:"json",
				success:function (responseData) {
					/*
						 responseData的值应该为：{isSuccess:true/false, errorMsg:"登陆失败的提示信息"}
						 其中 isSuccess的值若为true，表示登陆成功，反之表示登陆失败
					*/
					if(responseData.isSuccess){
						// 登陆成功，进入系统界面
						window.location.href = "workbench/index.jsp";
					}else{
						// 登录失败，显示错误信息
						$("#errorMsg").html(responseData.errorMsg);
					}
				}
			})

		}
		
	</script>

</head>


<body>
	<div style="position: absolute; top: 0px; left: 0px; width: 60%;">
		<img src="image/IMG_7114.JPG" style="width: 100%; height: 90%; position: relative; top: 50px;">
	</div>
	<div id="top" style="height: 50px; background-color: #3C3C3C; width: 100%;">
		<div style="position: absolute; top: 5px; left: 0px; font-size: 30px; font-weight: 400; color: white; font-family: 'times new roman'">CRM &nbsp;<span style="font-size: 12px;">&copy;2017&nbsp;动力节点</span></div>
	</div>
	
	<div style="position: absolute; top: 120px; right: 100px;width:450px;height:400px;border:1px solid #D5D5D5">
		<div style="position: absolute; top: 0px; right: 60px;">
			<div class="page-header">
				<h1>登录</h1>
			</div>
			<form action="workbench/index.jsp" class="form-horizontal" role="form">
				<div class="form-group form-group-lg">
					<div style="width: 350px;">
						<input id= "loginAct" class="form-control" type="text" placeholder="用户名">
					</div>
					<div style="width: 350px; position: relative;top: 20px;">
						<input id="loginPwd" class="form-control" type="password" placeholder="密码">
					</div>
					<div class="checkbox"  style="position: relative;top: 30px; left: 10px;">

							<!--登录验证的提示信息-->
							<span id="errorMsg" style="color:red"></span>
						
					</div>
					<!--
						在<form>标签中的<button>标签，其type属性的值默认是"submit"
						在这里先修改为"button"，方便我们测试登录验证功能
					-->
					<button type="button" id="submitBtn" class="btn btn-primary btn-lg btn-block"  style="width: 350px; position: relative;top: 45px;">登录</button>
				</div>
			</form>
		</div>
	</div>
</body>

</html>