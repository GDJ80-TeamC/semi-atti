<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="atti.*"%>   
<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>
<!-------------------- 
 * 기능 번호  : #21
 * 상세 설명  : 펫 정보 등록 페이지(액션)
 * 시작 날짜 : 2024-05-13
 * 담당자 : 김지훈
 -------------------->
 
<%
	System.out.println("--------------------");
	System.out.println("petRegiAction.jsp");
%>
<!-- Controller layer  -->
<%
	// 로그인한 사용자인지 검증
	if(session.getAttribute("loginEmp") == null){
		response.sendRedirect("/atti/view/loginForm.jsp");
		return;
	}
	
	// petRegiForm -> petRegiAction
	int customerNo = Integer.parseInt(request.getParameter("customerNo"));
	String empMajor = request.getParameter("empMajor");
	String petKind = request.getParameter("petKind");
	String petName = request.getParameter("petName");
	String petBirth = request.getParameter("petBirth");
	
	// form -> action 파라미터값 확인
	//System.out.println("customerNo: " + customerNo);
	//System.out.println("empMajor: " + empMajor);
	//System.out.println("petKind: " + petKind);
	//System.out.println("petName: " + petName);
	//System.out.println("petBirth: " + petBirth);
	
	// 펫 등록 실패 시 보여질 에러 메시지
	String errorMsg = null;
	
	if(empMajor == null || empMajor.trim().isEmpty()) { // empMajor가 null이거나 공백일 시
		errorMsg = URLEncoder.encode("의사 전공이 입력되지 않았으니 확인해 주세요", "UTF-8");
	} else if(petKind == null || petKind.trim().isEmpty() || !petKind.matches("[a-zA-Z가-힣]+")) { // petKind가 null이거나 공백일 시
		errorMsg = URLEncoder.encode("동물 종류가 입력되지 않았으니 확인해 주세요", "UTF-8");
	} else if(petName == null || petName.trim().isEmpty() || !petName.matches("[a-zA-Z가-힣]+")) { // petName이 null이거나 공백일 시
		errorMsg = URLEncoder.encode("이름이 입력되지 않았으니 확인해 주세요", "UTF-8");
	} else if(petBirth == null || petBirth.trim().isEmpty()) { // petBirth가 null이거나 공백일 시
		errorMsg = URLEncoder.encode("생일이 입력되지 않았으니 확인해 주세요", "UTF-8");
	}	
	System.out.println("errorMsg: " + errorMsg);
%>
<!-- model layer -->
<%
	// errorMsg가 null일 경우 메소드 실행
	if(errorMsg == null) {
		int insertRow = PetDao.petRegistration(customerNo, empMajor, petKind, petName, petBirth);
		if(insertRow > 0) { // insertRow가 1 이상이라면
			System.out.println("펫 등록 성공");
			response.sendRedirect("/atti/view/customerDetail.jsp?customerNo=" + customerNo);
			// 펫 등록에 성공했다면 customerDetail로 redirect
		} else {
			System.out.println("펫 등록 실패");
			response.sendRedirect("/atti/view/petRegiForm.jsp?customerNo=" + customerNo + "&" + "errorMsg=" + errorMsg);
			// 펫 등록에 실패했다면 에러 메시지와 함께 petRegiForm으로 redirect
		} 
	} else {
		System.out.println("펫 등록 실패");
		response.sendRedirect("/atti/view/petRegiForm.jsp?customerNo=" + customerNo + "&" + "errorMsg=" + errorMsg);
		// 펫 등록에 실패했다면 에러 메시지와 함께 petRegiForm으로 redirect
	} 
%>