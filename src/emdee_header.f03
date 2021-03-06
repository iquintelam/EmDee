!   This file is part of EmDee.
!
!    EmDee is free software: you can redistrc_intute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation, either version 3 of the License, or
!    (at your option) any later version.
!
!    EmDee is distrc_intuted in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    GNU General Public License for more details.
!
!    You should have received a copy of the GNU General Public License
!    along with EmDee. If not, see <http://www.gnu.org/licenses/>.
!
!    Author: Charlles R. A. Abreu (abreu@eq.ufrj.br)
!            Applied Thermodynamics and Molecular Simulation
!            Federal University of Rio de Janeiro, Brazil

module EmDee

use iso_c_binding

implicit none

type, bind(C) :: tOptions
  logical(c_bool) :: translate      ! Flag to activate/deactivate translations
  logical(c_bool) :: rotate         ! Flag to activate/deactivate rotations
  logical(c_bool) :: computeProps   ! Flag to activate/deactivate energy computations
  integer(c_int)  :: rotationMode   ! Algorithm used for free rotation of rigid bodies
end type tOptions

type, bind(C) :: tEmDee
  integer(c_int)  :: builds         ! Number of neighbor-list builds
  real(c_double)  :: pairTime       ! Time taken in force calculations
  real(c_double)  :: totalTime      ! Total time since initialization
  real(c_double)  :: Potential      ! Total potential energy of the system
  real(c_double)  :: Kinetic        ! Total kinetic energy of the system
  real(c_double)  :: Rotational     ! Rotational kinetic energy of the system
  real(c_double)  :: Virial         ! Total internal virial of the system
  integer(c_int)  :: DOF            ! Total number of degrees of freedom
  integer(c_int)  :: RDOF           ! Number of rotational degrees of freedom
  logical(c_bool) :: UpToDate       ! Flag to attest whether energies have been computed
  type(c_ptr)     :: Data           ! Pointer to EmDee system data
  type(tOptions)  :: Options        ! List of options to change EmDee's behavior
end type tEmDee

interface

  function EmDee_system( threads, layers, rc, skin, N, types, masses, bodies ) &
    bind(C,name="EmDee_system")
    import :: c_int, c_double, c_ptr, tEmDee
    integer(c_int), value :: threads, layers, N
    real(c_double), value :: rc, skin
    type(c_ptr),    value :: types, masses, bodies
    type(tEmDee)          :: EmDee_system
  end function EmDee_system

  subroutine EmDee_switch_model_layer( md, layer ) &
    bind(C,name="EmDee_switch_model_layer")
    import :: c_int, c_ptr, tEmDee
    type(tEmDee),   value :: md
    integer(c_int), value :: layer
  end subroutine EmDee_switch_model_layer

  subroutine EmDee_set_pair_model( md, itype, jtype, model, kCoul ) &
    bind(C,name="EmDee_set_pair_model")
    import :: c_int, c_ptr, c_double, tEmDee
    type(tEmDee),   value :: md
    integer(c_int), value :: itype, jtype
    type(c_ptr),    value :: model
    real(c_double), value :: kCoul
  end subroutine EmDee_set_pair_model

  subroutine EmDee_set_pair_multimodel( md, itype, jtype, model, kCoul ) &
    bind(C,name="EmDee_set_pair_multimodel")
    import :: c_int, c_ptr, c_double, tEmDee
    type(tEmDee),   value :: md
    integer(c_int), value :: itype, jtype
    type(c_ptr),    intent(in) :: model(*)
    real(c_double), intent(in) :: kCoul(*)
  end subroutine EmDee_set_pair_multimodel

  subroutine EmDee_set_coul_model( md, model ) &
    bind(C,name="EmDee_set_coul_model")
    import :: c_ptr, tEmDee
    type(tEmDee), value :: md
    type(c_ptr),  value :: model
  end subroutine EmDee_set_coul_model

  subroutine EmDee_set_coul_multimodel( md, model ) &
    bind(C,name="EmDee_set_coul_multimodel")
    import :: c_ptr, tEmDee
    type(tEmDee), value      :: md
    type(c_ptr),  intent(in) :: model(*)
  end subroutine EmDee_set_coul_multimodel

  subroutine EmDee_ignore_pair( md, i, j ) &
    bind(C,name="EmDee_ignore_pair")
    import :: c_int, c_ptr, tEmDee
    type(tEmDee),   value :: md
    integer(c_int), value :: i, j
  end subroutine EmDee_ignore_pair

  subroutine EmDee_add_bond( md, i, j, model ) &
    bind(C,name="EmDee_add_bond")
    import :: c_int, c_ptr, tEmDee
    type(tEmDee),   value :: md
    integer(c_int), value :: i, j
    type(c_ptr),    value :: model
  end subroutine EmDee_add_bond

  subroutine EmDee_add_angle( md, i, j, k, model ) &
    bind(C,name="EmDee_add_angle")
    import :: c_int, c_ptr, tEmDee
    type(tEmDee),   value :: md
    integer(c_int), value :: i, j, k
    type(c_ptr),    value :: model
  end subroutine EmDee_add_angle

  subroutine EmDee_add_dihedral( md, i, j, k, l, model ) &
    bind(C,name="EmDee_add_dihedral")
    import :: c_int, c_ptr, tEmDee
    type(tEmDee),   value :: md
    integer(c_int), value :: i, j, k, l
    type(c_ptr),    value :: model
  end subroutine EmDee_add_dihedral

  subroutine EmDee_upload( md, item, address ) &
    bind(C,name="EmDee_upload")
    import :: c_ptr, c_char, tEmDee
    type(tEmDee),      intent(inout) :: md
    character(c_char), intent(in)    :: item(*)
    type(c_ptr),       value         :: address
  end subroutine EmDee_upload

  subroutine EmDee_download( md, item, address ) &
    bind(C,name="EmDee_download")
    import :: c_ptr, c_char, tEmDee
    type(tEmDee),      value      :: md
    character(c_char), intent(in) :: item(*)
    type(c_ptr),       value      :: address
  end subroutine EmDee_download

  subroutine EmDee_random_momenta( md, kT, adjust, seed ) &
    bind(C,name="EmDee_random_momenta")
    import :: c_int, c_double, c_ptr, tEmDee
    type(tEmDee),   intent(inout) :: md
    real(c_double), value         :: kT
    integer(c_int), value         :: adjust, seed
  end subroutine EmDee_random_momenta

!  subroutine EmDee_save_state( md, rigid )
!    import: tEmDee, c_int
!    type(tEmDee),   intent(inout) :: md
!    integer(c_int), intent(in)    :: rigid
!  end subroutine EmDee_save_state

!  subroutine EmDee_restore_state( md )
!    import :: tEmDee
!    type(tEmDee), intent(inout) :: md
!  end subroutine EmDee_restore_state

  subroutine EmDee_boost( md, lambda, alpha, dt ) &
    bind(C,name="EmDee_boost")
    import :: c_double, c_ptr, tEmDee
    type(tEmDee),   intent(inout) :: md
    real(c_double), value         :: lambda, alpha, dt
  end subroutine EmDee_boost

  subroutine EmDee_move( md, lambda, alpha, dt ) &
    bind(C,name="EmDee_move")
    import :: c_double, c_ptr, tEmDee
    type(tEmDee),   intent(inout) :: md
    real(c_double), value         :: lambda, alpha, dt
  end subroutine EmDee_move

  ! TEMPORARY:
  subroutine EmDee_Rotational_Energies( md, Kr ) &
    bind(C,name="EmDee_Rotational_Energies")
    import
    type(tEmDee),   value       :: md
    real(c_double), intent(out) :: Kr(3) 
  end subroutine EmDee_Rotational_Energies

  ! MODELS:
  type(c_ptr) function EmDee_pair_none( ) &
    bind(C,name="EmDee_pair_none")
    import :: c_ptr
  end function EmDee_pair_none

  type(c_ptr) function EmDee_coul_none( ) &
    bind(C,name="EmDee_coul_none")
    import :: c_ptr
  end function EmDee_coul_none

  type(c_ptr) function EmDee_bond_none( ) &
    bind(C,name="EmDee_bond_none")
    import :: c_ptr
  end function EmDee_bond_none

  type(c_ptr) function EmDee_angle_none( ) &
    bind(C,name="EmDee_angle_none")
    import :: c_ptr
  end function EmDee_angle_none

  type(c_ptr) function EmDee_dihedral_none( ) &
    bind(C,name="EmDee_dihedral_none")
    import :: c_ptr
  end function EmDee_dihedral_none

end interface
end module
