<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
/*
上面这条语句得到的结果是：basePath=http://localhost:8080/crm/
*/
%>


<html>
<head>
	<base href="<%=basePath%>">
	<meta charset="UTF-8">
	<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
	<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
	<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>

	<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;
	
	$(function(){
		$("#remark").focus(function(){
			if(cancelAndSaveBtnDefault){
				//设置remarkDiv的高度为130px
				$("#remarkDiv").css("height","130px");
				//显示
				$("#cancelAndSaveBtn").show("2000");
				cancelAndSaveBtnDefault = false;
			}
		});
		
		$("#cancelBtn").click(function(){
			//显示
			$("#cancelAndSaveBtn").hide();
			//设置remarkDiv的高度为130px
			$("#remarkDiv").css("height","90px");
			cancelAndSaveBtnDefault = true;
		});
		
		$(".remarkDiv").mouseover(function(){
			$(this).children("div").children("div").show();
		});
		
		$(".remarkDiv").mouseout(function(){
			$(this).children("div").children("div").hide();
		});
		
		$(".myHref").mouseover(function(){
			$(this).children("span").css("color","red");
		});
		
		$(".myHref").mouseout(function(){
			$(this).children("span").css("color","#E6E6E6");
		});

		// 为保存按钮绑定事件，添加市场活动备注信息
		$("#saveActRemarkBtn").click(function () {

			$.ajax({
				url : "workbench/activity/saveActRemark.do",
				data : {"noteContent":$.trim($("#remark").val()), "activityId":"${activityObj.id}"},
				type : "post",
				dataType : "json",
				success : function (respData) {
					// respData 应该为 {"isSuccess":true/false, "actRemarkObj":{"id":xxx, "noteContent":xxx, ...}}
					if(respData.isSuccess){
						// 备注添加成功
						var html = "";
						html += '<div id="'+ respData.actRemarkObj.id +'" class="remarkDiv" style="height: 60px;">';
						html += '<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">';
						html += '<div style="position: relative; top: -40px; left: 40px;" >';
						html += '<h5 id="a'+ element.id +'">'+ element.noteContent +'</h5>';
						html += '<font color="gray">市场活动</font> <font color="gray">-</font> <b>${activityObj.name}</b> <small style="color: gray;" id="b'+ element.id +'"> '+ respData.actRemarkObj.createTime +' 由'+  respData.actRemarkObj.createBy +'</small>';
						html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
						html += '<a class="myHref" href="javascript:void(0);" onclick="editRemark(\''+ element.id +'\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: red;"></span></a>'; // 修改
						html += '&nbsp;&nbsp;&nbsp;&nbsp;';
						// 对于动态生成的元素所触发的方法，如果该触发方法需要传递参数，那么传递的参数必须得是一个字符串格式的数据！！！！！
						html += '<a class="myHref" href="javascript:void(0);" onclick="deleteActRemark(\''+ respData.actRemarkObj.id +'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: red;"></span></a>'; // 删除
						html += '</div>';
						html += '</div>';
						html += '</div>';

						// 为前端添加相应的内容展示
						$("#remarkDiv").before(html);

						// 清空文本域中的信息
						$("#remark").val("");

					}else{
						alert("添加备注失败");
					}
				}
			})

		});

		// 为更新按钮绑定事件，执行市场活动备注信息的更新操作
		$("#updateRemarkBtn").click(function () {

			var id = $("#remarkId").val();
			var noteContent = $.trim($("#noteContent").val());

			$.ajax({
				url : "workbench/activity/updateActRemark.do",
				data : {"id":id, "noteContent":noteContent},
				type : "post",
				dataType : "json",
				success : function (respData) {
					// respData 应该为 {"isSuccess":true/false, "actRemarkObj":{"id":xxx, "noteContent":xxx, .....}}
					if(respData.isSuccess){

						// 更新前端标签的备注内容
						$("#a" + id).html(noteContent);

						// 更新前端标签的修改时间和修改人
						$("#b" + id).html(respData.actRemarkObj.editTime + " 由" + respData.actRemarkObj.editBy);

						// 更新完毕后，关闭模态窗口
						$("#editRemarkModal").modal("hide");

					}else{
						alert("更新市场活动备注信息失败");
					}
				}
			});
		});

		// 在页面加载完毕后，展示备注信息
		showActRemarkList();

	});

	// 展示备注信息
	function showActRemarkList() {
		$.ajax({
			url : "workbench/activity/showActRemarkList.do",
			data : {"activityId" : "${activityObj.id}"}, // 在js中使用EL表达式需要将EL表达式用双引号括起来
			type : "get",
			dataType : "json",
			success : function (respData) {
				// respData 应该为 [{"id" : xxx, "noteContent" : xxx, .....}, {备注信息2}, .....]
				var html = "";
				$.each(respData, function (index, element) {
					html += '<div id="'+ element.id +'" class="remarkDiv" style="height: 60px;">';
					html += '<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">';
					html += '<div style="position: relative; top: -40px; left: 40px;" >';
					html += '<h5 id="a'+ element.id +'">'+ element.noteContent +'</h5>';
					html += '<font color="gray">市场活动</font> <font color="gray">-</font> <b>${activityObj.name}</b> <small style="color: gray;" id="b'+ element.id +'"> '+ (element.editFlag==0 ? element.createTime : element.editTime) +' 由'+ (element.editFlag==0 ? element.createBy : element.editBy) +'</small>';
					html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
					html += '<a class="myHref" href="javascript:void(0);" onclick="editRemark(\''+ element.id +'\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: red;"></span></a>'; // 修改
					html += '&nbsp;&nbsp;&nbsp;&nbsp;';
					// 对于动态生成的元素所触发的方法，如果该触发方法需要传递参数，那么传递的参数必须得是一个字符串格式的数据！！！！！
					html += '<a class="myHref" href="javascript:void(0);" onclick="deleteActRemark(\''+ element.id +'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: red;"></span></a>'; // 删除
					html += '</div>';
					html += '</div>';
					html += '</div>';
				});

				// 向id为remarkDiv的div标签的前面添加新的元素
				// 如果使用id为remarkBody的div元素的jquery对象的html()方法，将会清空id为remarkBody的div元素中的所有内容
				$("#remarkDiv").before(html);

				// 添加动画效果，不用记，直接复制
				$("#remarkBody").on("mouseover",".remarkDiv",function(){
					$(this).children("div").children("div").show();
				})
				$("#remarkBody").on("mouseout",".remarkDiv",function(){
					$(this).children("div").children("div").hide();
				})

			}
		})
	}

	// 删除备注
	function deleteActRemark(id) {

		if(confirm("确定删除该备注信息吗？")){
			$.ajax({
				url : "workbench/activity/deleteOneActRemark.do",
				data : {"id":id},
				type : "post",
				dataType : "json",
				success : function (respData) {
					// respData 应该为 {"isSuccess" : true/false}
					if(respData.isSuccess){
						// 刷新市场活动备注信息列表

						// 这种做法不行，记录的生成使用的是before()方法，每一次删除之后，页面都会保留原有的数据
						// showActRemarkList();

						// 在动态生成的div标签中添加id属性，属性值为每条备注的id值，然后找到记录对应存放的div标签，使用remove()方法进行删除
						$("#"+id).remove();

					}else{
						alert("删除备注失败");
					}
				}
			});
		}
	}

	// 打开修改备注信息的模态窗口，修改备注信息
	function editRemark(id) {

		// 将id值放到隐藏域中
		$("#remarkId").val(id);

		// 将h5标签中的备注内容放到修改备注的模态窗口的文本域中
		$("#noteContent").val($("#a"+id).html());

		// 打开修改备注的模态窗口
		$("#editRemarkModal").modal("show");
	}
	
	</script>

</head>
<body>
	
	<!-- 修改市场活动备注的模态窗口 -->
	<div class="modal fade" id="editRemarkModal" role="dialog">
		<%-- 备注的id --%>
		<input type="hidden" id="remarkId">
        <div class="modal-dialog" role="document" style="width: 40%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myModalLabel">修改备注</h4>
                </div>
                <div class="modal-body">
                    <form class="form-horizontal" role="form">
                        <div class="form-group">
                            <label for="edit-describe" class="col-sm-2 control-label">内容</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="noteContent"></textarea>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button type="button" class="btn btn-primary" id="updateRemarkBtn">更新</button>
                </div>
            </div>
        </div>
    </div>

    <!-- 修改市场活动的模态窗口 -->
    <div class="modal fade" id="editActivityModal" role="dialog">
        <div class="modal-dialog" role="document" style="width: 85%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myModalLabel">修改市场活动</h4>
                </div>
                <div class="modal-body">

                    <form class="form-horizontal" role="form">

                        <div class="form-group">
                            <label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <select class="form-control" id="edit-marketActivityOwner">
                                    <option>zhangsan</option>
                                    <option>lisi</option>
                                    <option>wangwu</option>
                                </select>
                            </div>
                            <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-marketActivityName" value="发传单">
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-startTime" value="2020-10-10">
                            </div>
                            <label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-endTime" value="2020-10-20">
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="edit-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-cost" value="5,000">
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="edit-describe" class="col-sm-2 control-label">描述</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="edit-describe">市场活动Marketing，是指品牌主办或参与的展览会议与公关市场活动，包括自行主办的各类研讨会、客户交流会、演示会、新产品发布会、体验会、答谢会、年会和出席参加并布展或演讲的展览会、研讨会、行业交流会、颁奖典礼等</textarea>
                            </div>
                        </div>

                    </form>

                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button type="button" class="btn btn-primary" data-dismiss="modal">更新</button>
                </div>
            </div>
        </div>
    </div>

	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>市场活动-${activityObj.name} <small>${activityObj.startDate} ~ ${activityObj.endDate}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" data-toggle="modal" data-target="#editActivityModal"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${activityObj.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${activityObj.name}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>

		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">开始日期</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${activityObj.startDate}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">结束日期</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${activityObj.endDate}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">成本</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${activityObj.cost}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${activityObj.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${activityObj.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${activityObj.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${activityObj.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${activityObj.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
	</div>
	
	<!-- 备注 -->
	<div id="remarkBody" style="position: relative; top: 30px; left: 40px;">
		<div class="page-header">
			<h4>备注</h4>
		</div>
		
		<!-- 备注1 -->
		<%--<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>哎呦！</h5>
				<font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>--%>
		
		<!-- 备注2 -->
		<%--<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>呵呵！</h5>
				<font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>
				</div>
			</div>
		</div>--%>
		
		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" id="saveActRemarkBtn" class="btn btn-primary">保存</button>
				</p>
			</form>
		</div>
	</div>
	<div style="height: 200px;"></div>
</body>
</html>