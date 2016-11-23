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

module pair_lj_coul_module

use global
use pairModelClass
use pair_lj_module

type, extends(cPairModel) :: pair_lj_coul
  real(rb) :: epsilon, sigma
  real(rb) :: eps4, sigsq
  contains
    procedure :: setup => pair_lj_coul_setup
    procedure :: compute => pair_lj_coul_compute
    procedure :: mix => pair_lj_coul_mix
end type pair_lj_coul

contains

!---------------------------------------------------------------------------------------------------

  type(c_ptr) function EmDee_pair_lj_coul( epsilon, sigma ) bind(C,name="EmDee_pair_lj_coul")
    real(rb), value :: epsilon, sigma

    type(pair_lj_coul), pointer :: model

    allocate(model)
    call model % setup( [epsilon, sigma] )
    EmDee_pair_lj_coul = model % deliver()

  end function EmDee_pair_lj_coul

!---------------------------------------------------------------------------------------------------

  subroutine pair_lj_coul_setup( model, params )
    class(pair_lj_coul), intent(inout) :: model
    real(rb),       intent(in)    :: params(:)

    ! Model kind:
    model%kind = "lj_coul"

    ! Model parameters:
    model%epsilon = params(1)
    model%sigma = params(2)

    ! Pre-computed quantities:
    model%eps4 = 4.0_rb*model%epsilon
    model%sigsq = model%sigma**2

  end subroutine pair_lj_coul_setup

!---------------------------------------------------------------------------------------------------

  subroutine pair_lj_coul_compute( model, Eij, Wij, invR2, Qi, Qj )
    class(pair_lj_coul), intent(in)  :: model
    real(rb),       intent(out) :: Eij, Wij
    real(rb),       intent(in)  :: invR2, Qi, Qj

    include "compute_pair_lj_coul.f90"

  end subroutine pair_lj_coul_compute

!---------------------------------------------------------------------------------------------------

  function pair_lj_coul_mix( this, other ) result( mixed )
    class(pair_lj_coul),    intent(in) :: this
    class(cPairModel), intent(in) :: other
    class(cPairModel), pointer :: mixed

    select type (other)
      class is (pair_lj_coul)
        allocate(pair_lj_coul :: mixed)
        call mixed % setup( [sqrt(this%epsilon*other%epsilon), half*(this%sigma + other%sigma)] )
      class is (pair_lj)
        allocate(pair_lj :: mixed)
        call mixed % setup( [sqrt(this%epsilon*other%epsilon), half*(this%sigma + other%sigma)] )
      class default
        mixed => null()
    end select

  end function pair_lj_coul_mix

!---------------------------------------------------------------------------------------------------

end module pair_lj_coul_module