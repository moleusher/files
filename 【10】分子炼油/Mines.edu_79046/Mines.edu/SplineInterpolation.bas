Attribute VB_Name = "Module_SplineInterpolation"
Option Explicit

Function SplineInterpolate _
    (Value As Variant, Known_Xs As Object, Known_Ys As Object, Optional X_Given As Boolean = True) _
As Variant
'
'   Function to do spline interpolation in a table. The Known_Xs array can be either
'   monotonic increasing or decreasing.
'
'   Written 10/18/2009 (J.L. Jechura) based on the routine "Interpolate".
'   Updated 09/08/2014 (J.L. Jechura). Modified to allow an entered y value & iterate to find associated x value.
'
Dim nValues As Long, i As Integer, bAscend As Boolean
Dim Xs() As Variant, Ys() As Variant

'
'   Ensure that the x & y arrays have the same sizes.
    nValues = Known_Xs.Count
    If ((nValues <> Known_Ys.Count) Or (nValues <= 1)) Then
        SplineInterpolate = "#ArrayLengths!"
        Exit Function
    End If

'
'   Copy values from cells to arrays.
    Xs = Values2Array(Known_Xs)
    Ys = Values2Array(Known_Ys)
    
'
'   Check that the Known_Xs array is in monotonic ascending or descending order.
    bAscend = (Xs(2) > Xs(1))
    i = 2
    Do While i < nValues
        If (bAscend Eqv (Xs(i + 1) > Xs(i))) Then
            i = i + 1
        Else
            SplineInterpolate = "#OrderX!"
            Exit Function
        End If
    Loop
    
    
    SplineInterpolate = CubicSpline(Value, Xs, Ys, nValues, X_Given)
    
End Function
    
Private Function CubicSpline _
    (Value As Variant, Known_Xs() As Variant, Known_Ys() As Variant, nValues As Long, X_Given As Boolean) _
As Variant
'
'   Function to do spline interpolation between two arrays.
'
'   Ref:    Digital Computing & Numerical Methods (with FORTRAN-IV, WATFOR, & WATFIV Programming)
'           Brice Carnahan & James O. Wilkes
'           John Wiley & Sons, 1973
'           pp 307 - 309
'
'   Written 10/18/2009 (J.L. Jechura) based on the routine "LinearInterpolate".
'   Updated 09/08/2014 (J.L. Jechura). Modified to allow an entered y value & iterate to find associated x value.
'
Dim Phi() As Double, DeltaX() As Double, DeltaY() As Double, _
    Diagonal() As Double, Upper() As Double, Lower() As Double, Slope As Double
Dim i As Long, iRow As Long, _
    xDelta As Double, xValue As Double, xTol As Double, xResidual As Double, iIterations As Long, bConverged As Boolean
'
'
'   Determine number of points. Redimension the arrays for this number of points.
    ReDim Phi(1 To nValues), DeltaX(1 To nValues), DeltaY(1 To nValues), _
            Diagonal(1 To nValues), Upper(1 To nValues), Lower(1 To nValues), RHS(1 To nValues)
    
'
'   Calculate the differences in the X & Y values.
    DeltaX(1) = Known_Xs(2) - Known_Xs(1)
    DeltaY(1) = Known_Ys(2) - Known_Ys(1)
    iRow = 1
    For i = 2 To (nValues - 1)
        DeltaX(i) = Known_Xs(i + 1) - Known_Xs(i)
        DeltaY(i) = Known_Ys(i + 1) - Known_Ys(i)
    Next i
    
'
'   Set up the coefficients for the simulataneous equations. Solve for the Phi values.
    Upper(1) = 0
    Lower(1) = 0
    Diagonal(1) = 1
    Phi(1) = 0
    For i = 2 To (nValues - 1)
        Upper(i) = 1
        Lower(i) = DeltaX(i - 1) / DeltaX(i)
        Diagonal(i) = 2 * (1 + Lower(i))
        Phi(i) = 6 * (DeltaY(i) / DeltaX(i) - DeltaY(i - 1) / DeltaX(i - 1)) / DeltaX(i)
    Next i
    Upper(nValues) = 0
    Lower(nValues) = 0
    Diagonal(nValues) = 1
    Phi(nValues) = 0
    Call TriDiag(Lower, Diagonal, Upper, Phi, Phi, nValues)

'
'   Main option -- X value given, directly calculate associated Y value
'   Determine the row that starts to bracket the answer.
'   Determine the interpolated Value. If extrapolating then do so with the slope at the terminal point.
    If (X_Given) Then
        iRow = Locate(Value, Known_Xs)
        If (iRow = 1 And (Value - Known_Xs(2)) / (Known_Xs(1) - Known_Xs(2)) > 1) Then
            Slope = (-(Known_Xs(2) - Known_Xs(1)) ^ 2 * Phi(1)) / DeltaX(1) / 2 + _
                (Known_Ys(2) / DeltaX(1) - DeltaX(1) * Phi(2) / 6) - _
                (Known_Ys(1) / DeltaX(1) - DeltaX(1) * Phi(1) / 6)
            CubicSpline = Known_Ys(1) + Slope * (Value - Known_Xs(1))
        
        ElseIf (iRow = nValues - 1 And (Value - Known_Xs(iRow)) / (Known_Xs(iRow + 1) - Known_Xs(iRow)) > 1) Then
            Slope = ((Known_Xs(iRow + 1) - Known_Xs(iRow)) ^ 2 * Phi(iRow + 1)) / DeltaX(iRow) / 2 + _
                (Known_Ys(iRow + 1) / DeltaX(iRow) - DeltaX(iRow) * Phi(iRow + 1) / 6) - _
                (Known_Ys(iRow) / DeltaX(iRow) - DeltaX(iRow) * Phi(iRow) / 6)
            CubicSpline = Known_Ys(iRow + 1) + Slope * (Value - Known_Xs(iRow + 1))
        
        Else
            CubicSpline = ((Known_Xs(iRow + 1) - Value) ^ 3 * Phi(iRow) + (Value - Known_Xs(iRow)) ^ 3 * Phi(iRow + 1)) / DeltaX(iRow) / 6 + _
                (Known_Ys(iRow + 1) / DeltaX(iRow) - DeltaX(iRow) * Phi(iRow + 1) / 6) * (Value - Known_Xs(iRow)) + _
                (Known_Ys(iRow) / DeltaX(iRow) - DeltaX(iRow) * Phi(iRow) / 6) * (Known_Xs(iRow + 1) - Value)
        End If

'
'   Secondary option -- Y value given, iterate to determine associated X value
'   Determine the row that starts to bracket the answer.
'   Determine the interpolated Value. If extrapolating then do so with the slope at the terminal point.
    Else
        iRow = Locate(Value, Known_Ys)
        If (iRow = 1 And (Value - Known_Ys(2)) / (Known_Ys(1) - Known_Ys(2)) > 1) Then
            Slope = (-(Known_Xs(2) - Known_Xs(1)) ^ 2 * Phi(1)) / DeltaX(1) / 2 + _
                (Known_Ys(2) / DeltaX(1) - DeltaX(1) * Phi(2) / 6) - _
                (Known_Ys(1) / DeltaX(1) - DeltaX(1) * Phi(1) / 6)
            CubicSpline = Known_Xs(1) + (Value - Known_Ys(1)) / Slope
        
        ElseIf (iRow = nValues - 1 And (Value - Known_Ys(iRow)) / (Known_Ys(iRow + 1) - Known_Ys(iRow)) > 1) Then
            Slope = ((Known_Xs(iRow + 1) - Known_Xs(iRow)) ^ 2 * Phi(iRow + 1)) / DeltaX(iRow) / 2 + _
                (Known_Ys(iRow + 1) / DeltaX(iRow) - DeltaX(iRow) * Phi(iRow + 1) / 6) - _
                (Known_Ys(iRow) / DeltaX(iRow) - DeltaX(iRow) * Phi(iRow) / 6)
            CubicSpline = Known_Xs(iRow + 1) + (Value - Known_Ys(iRow + 1)) / Slope
        
'   Iterate to find associated X value. Initialize with value from linear interpolation. Perform Newton's method updates until
'   relative deviation is within tolerance.
        Else
            xTol = 0.00000001
            Slope = (Known_Ys(iRow + 1) - Known_Ys(iRow)) / (Known_Xs(iRow + 1) - Known_Xs(iRow))
            xValue = Known_Xs(iRow + 1) + (Value - Known_Ys(iRow + 1)) / Slope
            For iIterations = 1 To 20
                xResidual = ((Known_Xs(iRow + 1) - xValue) ^ 3 * Phi(iRow) + (xValue - Known_Xs(iRow)) ^ 3 * Phi(iRow + 1)) / DeltaX(iRow) / 6 + _
                    (Known_Ys(iRow + 1) / DeltaX(iRow) - DeltaX(iRow) * Phi(iRow + 1) / 6) * (xValue - Known_Xs(iRow)) + _
                    (Known_Ys(iRow) / DeltaX(iRow) - DeltaX(iRow) * Phi(iRow) / 6) * (Known_Xs(iRow + 1) - xValue)
                xResidual = xResidual - Value
                Slope = (-3 * (Known_Xs(iRow + 1) - xValue) ^ 2 * Phi(iRow) + 3 * (xValue - Known_Xs(iRow)) ^ 2 * Phi(iRow + 1)) / DeltaX(iRow) / 6 + _
                    (Known_Ys(iRow + 1) / DeltaX(iRow) - DeltaX(iRow) * Phi(iRow + 1) / 6) - _
                    (Known_Ys(iRow) / DeltaX(iRow) - DeltaX(iRow) * Phi(iRow) / 6)
                xDelta = -xResidual / Slope
                bConverged = Abs(xValue + xDelta) <= Abs(xValue * xTol)
                xValue = xValue + xDelta
                If (bConverged) Then Exit For
            Next iIterations
            CubicSpline = xValue
        End If
        
    End If
    
    End Function

Sub TriDiag _
    (a() As Double, b() As Double, c() As Double, d() As Double, v() As Double, n As Long)
'
'   Routine to solve for a vector u(1 to n) in the tridiagonal linear set given by Av=d where:
'       a(2 to n) is the lower diagonal
'       b(1 to n) is the diagonal
'       c(1 to n-1) is the upper diagonal.
'
'   1st Source: Applied Numerical Methods
'               B. Carnahan, H.A. Luther, J.O. Wilkes
'               John Wiley & Sons, 1969
'               pp 441-446
'   2nd Source: Numerical Recipes in Fortran 77, 2nd ed.
'               W.H. Press, S.A. Teukolsky, W.T. Vetterling, B.P. Flannery
'               Cambridge University Press, 1996
'               pp 42-43
'   Written & last updated 10/18/2009 (JL Jechura).
'
Dim i As Long
Dim beta() As Double
Dim gamma() As Double
'
' Size gamma appropriate for problem
    ReDim beta(1 To n)
    ReDim gamma(1 To n)
    
'
' Decomposition & forward substituation
    beta(1) = b(1)
    gamma(1) = d(1) / beta(1)
    For i = 2 To n
        beta(i) = b(i) - a(i) * c(i - 1) / beta(i - 1)
        gamma(i) = (d(i) - a(i) * gamma(i - 1)) / beta(i)
    Next i
    
'
' Back substitution.
    v(n) = gamma(n)
    For i = n - 1 To 1 Step -1
        v(i) = gamma(i) - c(i) * v(i + 1) / beta(i)
    Next i
    

End Sub


Private Function Locate(X_Value As Variant, Known_Xs() As Variant) As Variant
'
'   Returns the index value in "known_xs" that precedes the given "x_value".  Bisection method
'   used.
'
'   Based on Fortran code in _Numerical Recipes in Fortran 77, 2nd ed._, WH Press, SA Teukolsky, WT Vetterling, & BP Flannery, 1992, pg. 111.
'
'   Written 08/31/2001 (JL Jechura).
'
Dim jFirst As Long, jLast As Long
Dim jLow As Long, jMid As Long, jUpper As Long
Dim bAscend As Boolean

'
' Initialize lower & upper limits.  Initialize logical flag for ascending data.
' Code using VB arrays.
    jFirst = LBound(Known_Xs)
    jLast = UBound(Known_Xs)
    
    jLow = jFirst - 1
    jUpper = jLast + 1
    bAscend = (Known_Xs(jLast) >= Known_Xs(jFirst))
    
    Do While ((jUpper - jLow) > 1)
        jMid = (jUpper + jLow) / 2
        If (bAscend = (X_Value >= Known_Xs(jMid))) Then
            jLow = jMid
        Else
            jUpper = jMid
        End If
    Loop

    Locate = WorksheetFunction.Max(jFirst, WorksheetFunction.Min(jLow, jLast - 1))

End Function

Private Function Values2Array(Original As Object) As Variant
'
'   Function to copy the values of an object to a single dimensioned array.
'
'   Written 10/24/2002 (JL Jechura).
'
Dim Values() As Variant
Dim nValues As Integer, i As Integer

    nValues = Original.Count
    ReDim Values(1 To nValues)
    For i = 1 To nValues
        Values(i) = Original(i)
    Next i
    
    Values2Array = Values
    
End Function


