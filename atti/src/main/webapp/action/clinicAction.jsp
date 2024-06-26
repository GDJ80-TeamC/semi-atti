<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="atti.*" %>
<%@ page import="java.net.*"%>
<%@ page import="java.util.*" %>
<!-------------------- 
 * 기능 번호  : #33
 * 상세 설명  : 진료 등록(액션)
 * 시작 날짜 : 2024-05-26
 * 담당자 : 김지훈
 -------------------->	
<%
	System.out.println("--------------------");
	System.out.println("clinicAction.jsp");
%>

<!-- Controller layer  -->
<%
	// 로그인한 사용자인지 검증
	if(session.getAttribute("loginEmp") == null){
		response.sendRedirect("/atti/view/loginForm.jsp");
		return;
	}
	
	
	int regiNo = Integer.parseInt(request.getParameter("regiNo"));
	int petNo = Integer.parseInt(request.getParameter("petNo"));
	String clinicCon = request.getParameter("clinicContent");
	String clnicDate = request.getParameter("clinicContentDate");
	String clinicContentDate = clnicDate.replace("T", " "); // T로 찍히는 값을 공백으로 치환
	
	String clinicError = null;
	if(clinicCon == null || clinicCon.trim().isEmpty()) { 
		// clinicContent가 null이거나 공백일 시
		clinicError = URLEncoder.encode("내용이 입력되지 않았습니다.", "UTF-8");
	}
	
	String clinicContent = "\n ["+clinicContentDate+"] "+clinicCon;
	// 디버깅
	System.out.println("regiNo: " + regiNo);
	System.out.println("petNo: " + petNo);
	System.out.println("clinicContent: " + clinicContent);
%>	
<!-- model layer -->
<%
	
	int updateRow = 0;
	if(clinicError == null) { // 진료 입력 시
		updateRow = ClinicDao.clinicUpdate(regiNo, clinicContent);
		System.out.println("ClinicDao#clinicUpdate: " + updateRow);
		
		if(updateRow > 0){
			System.out.println("진료 수정 성공");
			response.sendRedirect("/atti/view/clinicDetailForm.jsp?regiNo=" + regiNo + "&" + "petNo=" + petNo); // 진료 페이지로 이동
		} else {
			System.out.println("진료 수정 실패");
			response.sendRedirect("/atti/view/clinicDetailForm.jsp?regiNo=" + regiNo + "&" + "petNo=" + petNo); // 진료 페이지로 이동
		}
	} else {
		clinicError = URLEncoder.encode("진료 내용 등록 실패", "UTF-8");
		response.sendRedirect("/atti/view/clinicDetailForm.jsp?regiNo=" + regiNo + "&" + "petNo=" + petNo + "&" + "clinicError=" + clinicError);  
	}
%>