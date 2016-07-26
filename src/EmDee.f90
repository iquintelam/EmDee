!   This file is part of EmDee.
!
!    EmDee is free software: you can redistribute it and/or modify
!    it under the terms of the GNU General Public License as published by
!    the Free Software Foundation, either version 3 of the License, or
!    (at your option) any later version.
!
!    EmDee is distributed in the hope that it will be useful,
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

integer, parameter, private :: ib = c_int, rb = c_double

type, bind(C) :: EmDee_Model
  integer(ib) :: id = 0
  type(c_ptr) :: data = c_null_ptr
  real(rb)    :: p1 = 0.0_rb
  real(rb)    :: p2 = 0.0_rb
  real(rb)    :: p3 = 0.0_rb
  real(rb)    :: p4 = 0.0_rb
  integer(ib) :: external = 1
end type EmDee_Model

type, bind(C) :: tEmDee

  integer(ib) :: builds         ! Number of neighbor-list builds
  real(rb)    :: time           ! Total time taken in force calculations
  real(rb)    :: Rc             ! Cut-off distance
  real(rb)    :: RcSq           ! Cut-off distance squared
  real(rb)    :: xRc            ! Extended cutoff distance (including skin)
  real(rb)    :: xRcSq          ! Extended cutoff distance squared
  real(rb)    :: skinSq         ! Square of the neighbor list skin width
  real(rb)    :: eshift         ! Energy shifting factor for Coulombic interactions
  real(rb)    :: fshift         ! Force shifting factor for Coulombic interactions

  integer(ib) :: mcells         ! Number of cells at each dimension
  integer(ib) :: ncells         ! Total number of cells
  integer(ib) :: maxcells       ! Maximum number of cells
  integer(ib) :: maxatoms       ! Maximum number of atoms in a cell
  integer(ib) :: maxpairs       ! Maximum number of pairs formed by all atoms of a cell
  type(c_ptr) :: cell           ! Array containing all neighbor cells of each cell

  integer(ib) :: natoms         ! Number of atoms in the system
  type(c_ptr) :: atomType       ! The type of each atom
  type(c_ptr) :: atomMass       ! Pointer to the masses of all atoms
  type(c_ptr) :: R0             ! The position of each atom at the latest neighbor list building

  integer(ib) :: coulomb        ! Flag for coulombic interactions
  type(c_ptr) :: charge         ! Pointer to the electric charge of each atom

  integer(ib) :: ntypes         ! Number of atom types
  type(c_ptr) :: pairModel      ! Model of each type of atom pair

  type(c_ptr) :: bonds          ! List of bonds
  type(c_ptr) :: angles         ! List of angles
  type(c_ptr) :: dihedrals      ! List of dihedrals

  integer(ib) :: nbodies        ! Number of rigid bodies
  integer(ib) :: maxbodies      ! Maximum number of rigid bodies
  type(c_ptr) :: body           ! Pointer to the rigid bodies present in the system
  type(c_ptr) :: independent    ! Pointer to the status of each atom as independent or not

  real(rb)    :: Energy         ! Total potential energy of the system
  real(rb)    :: Virial         ! Total internal virial of the system

  integer(ib) :: nthreads       ! Number of parallel openmp threads
  type(c_ptr) :: cellAtom       ! List of atoms belonging to each cell
  type(c_ptr) :: threadCell     ! List of cells to be dealt with in each parallel thread
  type(c_ptr) :: neighbor       ! Pointer to neighbor lists
  type(c_ptr) :: excluded       ! List of pairs excluded from the neighbor lists

end type tEmDee

interface

  function EmDee_system( threads, rc, skin, N, types, masses ) result( me ) &
                                                               bind(C,name="EmDee_system")
    import :: ib, rb, c_ptr, tEmDee
    integer(ib), value :: threads, N
    real(rb),    value :: rc, skin
    type(c_ptr), value :: types, masses
    type(tEmDee)       :: me
  end function EmDee_system

  subroutine EmDee_set_charges( md, charges ) bind(C,name="EmDee_set_charges")
    import :: c_ptr
    type(c_ptr), value :: md, charges
  end subroutine EmDee_set_charges

  subroutine EmDee_set_pair_type( md, itype, jtype, model ) bind(C,name="EmDee_set_pair_type")
    import :: c_ptr, ib
    type(c_ptr), value :: md
    integer(ib), value :: itype, jtype
    type(c_ptr), value :: model
  end subroutine EmDee_set_pair_type

  subroutine EmDee_ignore_pair( md, i, j ) bind(C,name="EmDee_ignore_pair")
    import :: c_ptr, ib
    type(c_ptr), value :: md
    integer(ib), value :: i, j
  end subroutine EmDee_ignore_pair

  subroutine EmDee_add_bond( md, i, j, model ) bind(C,name="EmDee_add_bond")
    import :: c_ptr, ib
    type(c_ptr), value :: md
    integer(ib), value :: i, j
    type(c_ptr), value :: model
  end subroutine EmDee_add_bond

  subroutine EmDee_add_angle( md, i, j, k, model ) bind(C,name="EmDee_add_angle")
    import :: c_ptr, ib
    type(c_ptr), value :: md
    integer(ib), value :: i, j, k
    type(c_ptr), value :: model
  end subroutine EmDee_add_angle

  subroutine EmDee_add_dihedral( md, i, j, k, l, model ) bind(C,name="EmDee_add_dihedral")
    import :: c_ptr, ib
    type(c_ptr), value :: md
    integer(ib), value :: i, j, k, l
    type(c_ptr), value :: model
  end subroutine EmDee_add_dihedral

  subroutine EmDee_add_rigid_body( md, N, indexes, coords, L ) bind(C,name="EmDee_add_rigid_body")
    import :: c_ptr, ib, rb
    type(c_ptr), value :: md
    integer(ib), value :: N
    type(c_ptr), value :: indexes, coords
    real(rb),    value :: L
  end subroutine EmDee_add_rigid_body

  subroutine EmDee_compute( md, forces, coords, L ) bind(C,name="EmDee_compute")
    import :: c_ptr, rb
    type(c_ptr), value :: md, forces, coords
    real(rb),    value :: L
  end subroutine EmDee_compute

  function EmDee_pair_none( ) result(model) bind(C,name="EmDee_pair_none")
    import :: EmDee_Model
    type(EmDee_Model) :: model
  end function EmDee_pair_none

  function EmDee_pair_lj( epsilon, sigma ) result(model) bind(C,name="EmDee_pair_lj")
    import :: rb, EmDee_Model
    real(rb), value   :: epsilon, sigma
    type(EmDee_Model) :: model
  end function EmDee_pair_lj

  function EmDee_pair_lj_sf( epsilon, sigma, cutoff ) result(model) bind(C,name="EmDee_pair_lj_sf")
    import :: rb, EmDee_Model
    real(rb), value   :: epsilon, sigma, cutoff
    type(EmDee_Model) :: model
  end function EmDee_pair_lj_sf

  function EmDee_bond_harmonic( k, r0 ) result(model) bind(C,name="EmDee_bond_harmonic")
    import :: rb, EmDee_Model
    real(rb), value :: k, r0
    type(EmDee_Model) :: model
  end function EmDee_bond_harmonic

  function EmDee_bond_morse( D, alpha, r0 ) result(model) bind(C,name="EmDee_bond_morse")
    import :: rb, EmDee_Model
    real(rb), value :: D, alpha, r0
    type(EmDee_Model) :: model
  end function EmDee_bond_morse

  function EmDee_angle_harmonic( k, theta0 ) result(model) bind(C,name="EmDee_angle_harmonic")
    import :: rb, EmDee_Model
    real(rb), value :: k, theta0
    type(EmDee_Model) :: model
  end function EmDee_angle_harmonic

  function EmDee_dihedral_harmonic( k, phi0 ) result(model) bind(C,name="EmDee_dihedral_harmonic")
    import :: rb, EmDee_Model
    real(rb), value :: k, phi0
    type(EmDee_Model) :: model
  end function EmDee_dihedral_harmonic

end interface

end module EmDee


