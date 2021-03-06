!=================================================
! The integrate module of SPS-dynamic.
!-------------------------------------------------
! Version: 0.2
! Author: Zhu F.
! Email: lyricorpse@gmail.com
! Date: 2013-05-04 13:59:46 
! Copyright: This software is provided under a CC BY-NC-SA 3.0 License(http://creativecommons.org/licenses/by-nc-sa/3.0/deed.zh)
!=================================================
MODULE sp_module_integrate
USE sp_module_constant
USE sp_module_model
USE sp_module_gridvar
USE sp_module_timeschemes
USE sp_module_boundary
USE sp_module_subgrid
USE sp_module_wsm6
USE sp_module_cldfra
USE sp_module_debug
IMPLICIT NONE
!=================================================
CONTAINS
!=================================================
SUBROUTINE integrate(step,uGrid,wGrid,piGrid,virGrid)
IMPLICIT NONE
INTEGER, INTENT(IN) :: step
TYPE(grid), INTENT(INOUT) :: uGrid, wGrid, piGrid, virGrid
TYPE(mainvar) :: mid, new
INTEGER :: i, k
!=================================================
CALL subgrid(uGrid,wGrid,piGrid,virGrid)

IF (Vapor == 1) THEN
	IF (step /= 1) THEN
		CALL set_area_w
		CALL mp_wsm6(imin,imax,kmin,kmax,mid,wGrid)
		!$OMP PARALLEL DO
		DO k = kmin, kmax
			DO i = imin, imax
				wGrid%Mtheta(i,k) = (mid%theta(i,k) - wGrid%theta(i,k))/dt
				wGrid%Mqv(i,k) = (mid%qv(i,k) - wGrid%qv(i,k))/dt
				wGrid%Mqc(i,k) = (mid%qc(i,k) - wGrid%qc(i,k))/dt
				wGrid%Mqr(i,k) = (mid%qr(i,k) - wGrid%qr(i,k))/dt
				wGrid%Mqi(i,k) = (mid%qi(i,k) - wGrid%qi(i,k))/dt
				wGrid%Mqs(i,k) = (mid%qs(i,k) - wGrid%qs(i,k))/dt
				wGrid%Mqg(i,k) = (mid%qg(i,k) - wGrid%qg(i,k))/dt
			END DO
		END DO
		!$OMP END PARALLEL DO
		CALL calc_cldfra(wGrid)
		!CALL calc_cldfra2(wGrid)
	END IF
END IF

SELECT CASE (TimeScheme)
CASE (1)
	! Runge-Kutta Scheme
	CALL runge_kutta(uGrid,wGrid,piGrid,virGrid,new)
CASE DEFAULT
	STOP "Wrong time differencing scheme!!!"
END SELECT

! update u, w, pi_1, theta, theta_1
uGrid%u = new%u
wGrid%w = new%w
piGrid%pi_1 = new%pi_1
wGrid%theta = new%theta
wGrid%qv = new%qv
wGrid%qc = new%qc
wGrid%qr = new%qr
wGrid%qi = new%qi
wGrid%qs = new%qs
wGrid%qg = new%qg
!=================================================
END SUBROUTINE integrate
!=================================================

!=================================================
END MODULE sp_module_integrate
!=================================================
