using OffsetArrays
using Base.Test
ambs = detect_ambiguities(Base, Core)  # in case these have ambiguities of their own
using PaddedViews
@test isempty(setdiff(detect_ambiguities(PaddedViews, Base, Core), ambs))

# Basics
for n = 0:5
    a = @inferred(PaddedView(0, ones(Int,ntuple(d->1,n)), ntuple(x->x+1,n)))
    @test indices(a) == ntuple(x->1:x+1,n)
    @test @inferred(a[1]) == 1
    n > 0 && @test @inferred(a[2]) == 0
    @test @inferred(a[ntuple(x->1,n)...]) == 1
    n > 0 && @test @inferred(a[2, ntuple(x->1,n-1)...]) == 0
end
a0 = reshape([3])
a = @inferred(PaddedView(-1, a0, ()))
@test indices(a) == ()
@test ndims(a) == 0
@test a[] == 3

a = reshape(1:9, 3, 3)
A = @inferred(PaddedViews.PaddedView(0.0, a, (Base.OneTo(4), Base.OneTo(5))))
@test eltype(A) == Int
@test ndims(A) == 2
@test size(A) === (4,5)
@test @inferred(indices(A)) === (Base.OneTo(4), Base.OneTo(5))
@test @inferred(indices(A, 3)) === Base.OneTo(1)
@test A == [1 4 7 0 0;
            2 5 8 0 0;
            3 6 9 0 0;
            0 0 0 0 0]

A = @inferred(PaddedViews.PaddedView(0.0, a, (0:4, -1:5)))
@test eltype(A) == Int
@test ndims(A) == 2
@test_throws ErrorException size(A)
@test @inferred(indices(A)) === (0:4, -1:5)
@test @inferred(indices(A, 3)) === 1:1
@test A == OffsetArray([0 0 0 0 0 0 0;
                        0 0 1 4 7 0 0;
                        0 0 2 5 8 0 0;
                        0 0 3 6 9 0 0;
                        0 0 0 0 0 0 0], 0:4, -1:5)

a1 = reshape([1,2], 2, 1)
a2 = [1.0,2.0]'
a1p, a2p = @inferred(paddedviews(0, a1, a2))
@test a1p == [1 0; 2 0]
@test a2p == [1.0 2.0; 0.0 0.0]
@test eltype(a1p) == Int
@test eltype(a2p) == Float64
@test indices(a1p) === indices(a2p) === (Base.OneTo(2), Base.OneTo(2))

a3 = OffsetArray([1.0,2.0]', (0,-1))
a1p, a3p = @inferred(paddedviews(0, a1, a3))
@test a1p == OffsetArray([0 1; 0 2], 1:2, 0:1)
@test a3p == OffsetArray([1.0 2.0; 0.0 0.0], 1:2, 0:1)
@test eltype(a1p) == Int
@test eltype(a3p) == Float64
@test indices(a1p) === indices(a3p) === (1:2, 0:1)

nothing
