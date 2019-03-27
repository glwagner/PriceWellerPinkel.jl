#
# Tests for the Diffusion module
#

function test_diffusion_basic()
    model = Diffusion.Model(N=4, L=2, κ=0.1)
    model.parameters.κ == 0.1
end

function test_diffusion_set_c()
    model = Diffusion.Model(N=4, L=2, κ=0.1)
    c0 = 1:4
    model.solution.c = c0
    model.solution.c.data[1:model.grid.N] == c0
end

function test_diffusion_cosine()
    model = Diffusion.Model(N=100, L=π/2, κ=1)
    z = model.grid.zc

    c_init(z) = cos(2z)
    c_ans(z, t) = exp(-4t) * c_init(z)

    model.solution.c = c_init

    dt = 1e-3
    iterate!(model, dt)

    # The error tolerance is a bit arbitrary.
    norm(c_ans.(z, time(model)) .- data(model.solution.c)) < model.grid.N*1e-6
end

function test_diffusive_flux()
    model = Diffusion.Model(N=10, L=1, κ=1)
    top_flux = 0.3
    bottom_flux = 0.13
    model.bcs.c.top = FluxBoundaryCondition(top_flux)
    model.bcs.c.bottom = FluxBoundaryCondition(bottom_flux)

    C₀ = integral(model.solution.c)
    C(t) = C₀ - (top_flux - bottom_flux) * t

    dt = 1e-6
    iterate!(model, dt, 10)

    return C(time(model)) ≈ integral(model.solution.c)
end