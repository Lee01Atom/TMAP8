cl = 3.1622e18 # atom/m^3
N = 3.1622e22 # atom/m^3
epsilon_1 = 100 # K
epsilon_2 = 500 # K
epsilon_3 = 800 # K
temperature = 1000 # K
nx_num = 1000 # (-)
trapping_site_fraction_1 = 0.10 # (-)
trapping_site_fraction_2 = 0.15 # (-)
trapping_site_fraction_3 = 0.20 # (-)
trapping_rate_coefficient = 1e15 # 1/s
release_rate_coefficient = 1e13 # 1/s
diffusivity = 1 # m^2/s
simulation_time = 60 # s
time_interval_max = 0.3 # s

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = ${nx_num}
  xmax = 1
[]

[Problem]
  type = ReferenceResidualProblem
  extra_tag_vectors = 'ref'
  reference_vector = 'ref'
[]

[Variables]
  [mobile]
  []
  [trapped_1]
  []
  [trapped_2]
  []
  [trapped_3]
  []
[]

[AuxVariables]
  [empty_sites_1]
  []
  [scaled_empty_sites_1]
  []
  [empty_sites_2]
  []
  [scaled_empty_sites_2]
  []
  [empty_sites_3]
  []
  [scaled_empty_sites_3]
  []
  [trapped_sites_1]
  []
  [trapped_sites_2]
  []
  [trapped_sites_3]
  []
  [total_sites]
  []
[]

[AuxKernels]
  [empty_sites_1]
    variable = empty_sites_1
    type = EmptySitesAux
    N = '${fparse N / cl}'
    Ct0 = '${trapping_site_fraction_1}'
    trapped_concentration_variables = trapped_1
  []
  [scaled_empty_1]
    variable = scaled_empty_sites_1
    type = NormalizationAux
    normal_factor = '${cl}'
    source_variable = empty_sites_1
  []
  [empty_sites_2]
    variable = empty_sites_2
    type = EmptySitesAux
    N = '${fparse N / cl}'
    Ct0 = '${trapping_site_fraction_2}'
    trapped_concentration_variables = trapped_2
  []
  [scaled_empty_2]
    variable = scaled_empty_sites_2
    type = NormalizationAux
    normal_factor = '${cl}'
    source_variable = empty_sites_2
  []
  [empty_sites_3]
    variable = empty_sites_3
    type = EmptySitesAux
    N = '${fparse N / cl}'
    Ct0 = '${trapping_site_fraction_3}'
    trapped_concentration_variables = trapped_3
  []
  [scaled_empty_3]
    variable = scaled_empty_sites_3
    type = NormalizationAux
    normal_factor = '${cl}'
    source_variable = empty_sites_3
  []
  [trapped_sites_1]
    variable = trapped_sites_1
    type = NormalizationAux
    source_variable = trapped_1
  []
  [trapped_sites_2]
    variable = trapped_sites_2
    type = NormalizationAux
    source_variable = trapped_2
  []
  [trapped_sites_3]
    variable = trapped_sites_3
    type = NormalizationAux
    source_variable = trapped_3
  []
  [total_sites]
    variable = total_sites
    type = ParsedAux
    expression = 'trapped_sites_1 + trapped_sites_2 + trapped_sites_3 + empty_sites_1 + empty_sites_2 + empty_sites_3'
    coupled_variables = 'trapped_sites_1 trapped_sites_2 trapped_sites_3 empty_sites_1 empty_sites_2 empty_sites_3'
  []
[]

[Kernels]
  [diff]
    type = Diffusion
    variable = mobile
    extra_vector_tags = ref
  []
  [time]
    type = TimeDerivative
    variable = mobile
    extra_vector_tags = ref
  []
  [coupled_time_1]
    type = CoupledTimeDerivative
    variable = mobile
    v = trapped_1
    extra_vector_tags = ref
  []
  [coupled_time_2]
    type = CoupledTimeDerivative
    variable = mobile
    v = trapped_2
    extra_vector_tags = ref
  []
  [coupled_time_3]
    type = CoupledTimeDerivative
    variable = mobile
    v = trapped_3
    extra_vector_tags = ref
  []
[]

[NodalKernels]
  # For first traps
  [time_1]
    type = TimeDerivativeNodalKernel
    variable = trapped_1
  []
  [trapping_1]
    type = TrappingNodalKernel
    variable = trapped_1
    alpha_t = '${trapping_rate_coefficient}'
    N = '${fparse N / cl}'
    Ct0 = '${trapping_site_fraction_1}'
    mobile_concentration = 'mobile'
    temperature = '${temperature}'
    extra_vector_tags = ref
  []
  [release_1]
    type = ReleasingNodalKernel
    alpha_r = '${release_rate_coefficient}'
    temperature = '${temperature}'
    detrapping_energy = '${epsilon_1}'
    variable = trapped_1
  []
  # For second traps
  [time_2]
    type = TimeDerivativeNodalKernel
    variable = trapped_2
  []
  [trapping_2]
    type = TrappingNodalKernel
    variable = trapped_2
    alpha_t = '${trapping_rate_coefficient}'
    N = '${fparse N / cl}'
    Ct0 = '${trapping_site_fraction_2}'
    mobile_concentration = 'mobile'
    temperature = '${temperature}'
    extra_vector_tags = ref
  []
  [release_2]
    type = ReleasingNodalKernel
    alpha_r = '${release_rate_coefficient}'
    temperature = '${temperature}'
    detrapping_energy = '${epsilon_2}'
    variable = trapped_2
  []
  # For third traps
  [time_3]
    type = TimeDerivativeNodalKernel
    variable = trapped_3
  []
  [trapping_3]
    type = TrappingNodalKernel
    variable = trapped_3
    alpha_t = '${trapping_rate_coefficient}'
    N = '${fparse N / cl}'
    Ct0 = '${trapping_site_fraction_3}'
    mobile_concentration = 'mobile'
    temperature = '${temperature}'
    extra_vector_tags = ref
  []
  [release_3]
    type = ReleasingNodalKernel
    alpha_r = '${release_rate_coefficient}'
    temperature = '${temperature}'
    detrapping_energy = '${epsilon_3}'
    variable = trapped_3
  []
[]

[BCs]
  [left]
    type = DirichletBC
    variable = mobile
    value = '${fparse cl / cl}'
    boundary = left
  []
  [right]
    type = DirichletBC
    variable = mobile
    value = 0
    boundary = right
  []
[]

[Postprocessors]
  [outflux]
    type = SideDiffusiveFluxAverage
    boundary = 'right'
    diffusivity = '${diffusivity}'
    variable = mobile
  []
  [scaled_outflux]
    type = ScalePostprocessor
    value = outflux
    scaling_factor = '${cl}'
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  end_time = ${simulation_time}
  dtmax = ${time_interval_max}
  solve_type = NEWTON
  scheme = BDF2
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  line_search = 'none'
  [TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e-6
    optimal_iterations = 9
    growth_factor = 1.1
    cutback_factor = 0.909
  []
[]

[Outputs]
  exodus = true
  csv = true
  [dof]
    type = DOFMap
    execute_on = initial
  []
  perf_graph = true
[]
