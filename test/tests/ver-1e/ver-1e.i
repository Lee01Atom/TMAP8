T_PyC = ${units 33 mum -> m}
T_SiC = ${units 66 mum -> m}
D_ver = ${units 15.75 mum -> m}
[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 1000
  xmax = ${fparse ${T_PyC} + ${T_SiC} }
  allow_renumbering = false
[]

[Variables]
  [u]
  []
[]

[Functions]
  [diffusivity_value]
    type = ParsedFunction
    expression = 'if(x< ${units 33 mum -> m}, 1.274e-7, 2.622e-11)'
  []
[]

[Kernels]
  [diff]
    type = FunctionDiffusion
    variable = u
    function = diffusivity_value
  []
  [time]
    type = TimeDerivative
    variable = u
  []
[]

[BCs]
  [left]
    type = DirichletBC
    variable = u
    boundary = left
    value = 50.7079 # moles/m^3
  []
  [right]
    type = DirichletBC
    variable = u
    boundary = right
    value = 0
  []
[]

# Used while obtaining steady-state solution
#
[VectorPostprocessors]
  [line]
    type = LineValueSampler
    start_point = '0 0 0'
    end_point = '${Mesh/xmax} 0 0'
    num_points = ${Mesh/nx}
    sort_by = 'x'
    variable = u
    outputs = vector_postproc
  []
[]

[Postprocessors]
  # Used to obtain varying concentration with time at a
  # point in SiC layer 'x' um from IPyC/SiC boundary
  # x = 8 um for TMAP4 verification case,
  # x = 15.75 um for TMAP7 verification case
  [conc_at_x]
    type = PointValue
    variable = u
    point = '${fparse ${T_PyC} + ${D_ver}} 0 0'
    outputs = 'csv'
  []
[]

[Executioner]
  type = Transient
  end_time = 5000
  dtmax = 10
  solve_type = NEWTON
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  scheme = 'bdf2'
  nl_rel_tol = 1e-50 # Make this really tight so that our absolute tolerance criterion is the one
  # we must meet
  nl_abs_tol = 1e-12
  abort_on_solve_fail = true
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e-4
    optimal_iterations = 4
    growth_factor = 1.25
    cutback_factor = 0.8
  []
[]

[Outputs]
  [exodus]
    type = Exodus
  []
  [csv]
    type = CSV
  []
  [vector_postproc]
    type = CSV
    sync_times = 5000
    sync_only = true
  []
[]
